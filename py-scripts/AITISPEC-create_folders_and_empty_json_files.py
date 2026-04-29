import os

# Создаем папки
for i in range(1, 26):
	folder_name = f"{i:03d}"
	os.makedirs(folder_name, exist_ok=True)

	# В каждой папке создаем 25 пустых json файлов
	for j in range(1, 26):
		file_name = f"{folder_name}_{j:03d}.json"
		file_path = os.path.join(folder_name, file_name)
		# Создаем пустой json файл с помощью pass
		with open(file_path, 'w', encoding='utf-8') as f:
			pass

print("Папки и пустые json файлы созданы успешно!")
