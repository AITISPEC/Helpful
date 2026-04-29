# matrix_size_benchmark.py
import torch
import time

print("="*70)
print("MATRIX SIZE BENCHMARK - FINDING OPTIMAL SIZE FOR TENSOR CORES")
print("="*70)

# Настройки
torch.backends.cuda.matmul.allow_tf32 = True
torch.backends.cudnn.benchmark = True

print(f"GPU: {torch.cuda.get_device_name(0)}")
print(f"PyTorch: {torch.__version__}")
print(f"TF32 enabled: {torch.backends.cuda.matmul.allow_tf32}")

# Проверка Triton
try:
	import triton
	TRITON_AVAILABLE = True
	print(f"Triton: v{triton.__version__}")
except ImportError:
	TRITON_AVAILABLE = False
	print("Triton: Not available")

print("="*70)

def benchmark_matmul(size, iterations=100, warmup=10):
	"""Бенчмарк для одного размера матрицы"""
	results = {}

	# Очистка памяти
	torch.cuda.empty_cache()

	# Создаем данные
	a_fp32 = torch.randn(size, size, device='cuda')
	b_fp32 = torch.randn(size, size, device='cuda')
	a_fp16 = a_fp32.half()
	b_fp16 = b_fp32.half()

	# 1. PyTorch FP32/TF32
	# Разогрев
	for _ in range(warmup):
		torch.mm(a_fp32, b_fp32)
	torch.cuda.synchronize()

	# Замер
	start = time.perf_counter()
	for _ in range(iterations):
		torch.mm(a_fp32, b_fp32)
	torch.cuda.synchronize()
	t_fp32 = time.perf_counter() - start

	# 2. PyTorch FP16
	torch.cuda.synchronize()
	start = time.perf_counter()
	for _ in range(iterations):
		torch.mm(a_fp16, b_fp16)
	torch.cuda.synchronize()
	t_fp16 = time.perf_counter() - start

	# Расчет TFLOPS
	flops_per_op = 2 * size**3
	total_flops = flops_per_op * iterations

	tflops_fp32 = total_flops / t_fp32 / 1e12
	tflops_fp16 = total_flops / t_fp16 / 1e12
	speedup_fp16 = t_fp32 / t_fp16

	results.update({
		'size': size,
		'time_fp32': t_fp32,
		'time_fp16': t_fp16,
		'tflops_fp32': tflops_fp32,
		'tflops_fp16': tflops_fp16,
		'speedup_fp16': speedup_fp16,
	})

	# 3. Triton (если доступен)
	if TRITON_AVAILABLE:
		@torch.compile
		def matmul_triton(x, y):
			return torch.matmul(x, y)

		# Разогрев для JIT
		for _ in range(warmup * 2):
			matmul_triton(a_fp32, b_fp32)
			matmul_triton(a_fp16, b_fp16)

		# FP32
		torch.cuda.synchronize()
		start = time.perf_counter()
		for _ in range(iterations):
			matmul_triton(a_fp32, b_fp32)
		torch.cuda.synchronize()
		t_triton_fp32 = time.perf_counter() - start

		# FP16
		torch.cuda.synchronize()
		start = time.perf_counter()
		for _ in range(iterations):
			matmul_triton(a_fp16, b_fp16)
		torch.cuda.synchronize()
		t_triton_fp16 = time.perf_counter() - start

		tflops_triton_fp32 = total_flops / t_triton_fp32 / 1e12
		tflops_triton_fp16 = total_flops / t_triton_fp16 / 1e12
		speedup_triton_fp16 = t_triton_fp32 / t_triton_fp16

		results.update({
			'time_triton_fp32': t_triton_fp32,
			'time_triton_fp16': t_triton_fp16,
			'tflops_triton_fp32': tflops_triton_fp32,
			'tflops_triton_fp16': tflops_triton_fp16,
			'speedup_triton_fp16': speedup_triton_fp16,
			'speedup_vs_pytorch_fp32': t_fp32 / t_triton_fp32,
			'speedup_vs_pytorch_fp16': t_fp16 / t_triton_fp16,
		})

	return results

def run_benchmarks(sizes):
	"""Запуск бенчмарков для нескольких размеров"""
	all_results = []

	for size in sizes:
		print(f"\nTesting size {size}x{size}...")
		results = benchmark_matmul(size, iterations=50, warmup=5)
		all_results.append(results)

		# Вывод для этого размера
		print(f"  PyTorch FP32/TF32: {results['time_fp32']:.3f}s, {results['tflops_fp32']:.1f} TFLOPS")
		print(f"  PyTorch FP16:      {results['time_fp16']:.3f}s, {results['tflops_fp16']:.1f} TFLOPS")
		print(f"  Speedup FP16: {results['speedup_fp16']:.2f}x")

		if TRITON_AVAILABLE and 'time_triton_fp16' in results:
			print(f"  Triton FP16:       {results['time_triton_fp16']:.3f}s, {results['tflops_triton_fp16']:.1f} TFLOPS")
			print(f"  Triton vs PyTorch FP16: {results['speedup_vs_pytorch_fp16']:.2f}x")

	return all_results

def print_summary_table(results):
	"""Вывод сводной таблицы"""
	print("\n" + "="*90)
	print("SUMMARY TABLE")
	print("="*90)

	headers = ["Size", "PyTorch FP32 (TFLOPS)", "PyTorch FP16 (TFLOPS)", "Speedup", "Triton FP16 (TFLOPS)", "Triton Speedup"]

	# Определяем ширину колонок
	col_widths = [10, 22, 22, 12, 22, 15]

	# Заголовок
	header = " | ".join(h.center(w) for h, w in zip(headers, col_widths))
	print(header)
	print("-" * len(header))

	# Данные
	for r in results:
		size = r['size']
		pytorch_fp32_tflops = f"{r['tflops_fp32']:.1f}"
		pytorch_fp16_tflops = f"{r['tflops_fp16']:.1f}"
		speedup = f"{r['speedup_fp16']:.2f}x"

		if TRITON_AVAILABLE and 'tflops_triton_fp16' in r:
			triton_fp16_tflops = f"{r['tflops_triton_fp16']:.1f}"
			triton_speedup = f"{r['speedup_vs_pytorch_fp16']:.2f}x"
		else:
			triton_fp16_tflops = "N/A"
			triton_speedup = "N/A"

		row = [
			str(size),
			pytorch_fp32_tflops,
			pytorch_fp16_tflops,
			speedup,
			triton_fp16_tflops,
			triton_speedup,
		]

		print(" | ".join(item.center(w) for item, w in zip(row, col_widths)))

	print("="*90)

def find_optimal_size(results):
	"""Поиск оптимального размера для Tensor Cores"""
	best_fp16_speedup = 0
	best_fp16_tflops = 0
	best_size = 0

	for r in results:
		if r['speedup_fp16'] > best_fp16_speedup:
			best_fp16_speedup = r['speedup_fp16']
			best_fp16_tflops = r['tflops_fp16']
			best_size = r['size']

	print("\n" + "="*70)
	print("OPTIMAL SIZE FOR TENSOR CORES:")
	print("="*70)
	print(f"Best size: {best_size}x{best_size}")
	print(f"FP16 Speedup: {best_fp16_speedup:.2f}x")
	print(f"FP16 TFLOPS: {best_fp16_tflops:.1f}")
	print("="*70)

	return best_size

# Размеры для тестирования (степени двойки и близкие к ним)
sizes = [256, 512, 768, 1024, 1536, 2048, 3072, 4096]

# Запускаем бенчмарки
print(f"\nTesting sizes: {sizes}")
all_results = run_benchmarks(sizes)

# Выводим таблицу
print_summary_table(all_results)

# Находим оптимальный размер
find_optimal_size(all_results)

# Дополнительно: сравниваем с теоретическим максимумом
print("\n" + "="*70)
print("PERFORMANCE ANALYSIS:")
print("="*70)

# Теоретический максимум для RTX 3070
theoretical_fp32 = 20.3  # TFLOPS
theoretical_fp16 = 81.6  # TFLOPS

print(f"Theoretical FP32 TFLOPS: {theoretical_fp32:.1f}")
print(f"Theoretical FP16 TFLOPS: {theoretical_fp16:.1f}")

# Находим лучший результат по TFLOPS
best_result = max(all_results, key=lambda x: x['tflops_fp16'])
efficiency = (best_result['tflops_fp16'] / theoretical_fp16) * 100

print(f"\nBest achieved FP16 TFLOPS: {best_result['tflops_fp16']:.1f} at size {best_result['size']}")
print(f"Tensor Core efficiency: {efficiency:.1f}%")

print("\n" + "="*70)
print("RECOMMENDATIONS:")
print("="*70)
print("1. Use FP16 for sizes where speedup > 1.5x")
print("2. For matrix multiplications, choose sizes that are multiples of 256")
print("3. For attention layers, Triton may provide additional speedup")
print("4. Consider batch sizes that result in matrix dimensions close to optimal")
