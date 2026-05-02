import os
import json

# Данные для записи в каждый JSON файл
data_template = [
	{
		"role_1": "empty_pass",
		"topic": "empty_pass",
		"sub_topic": "empty_pass",
		"message_1": "empty_pass"
	}
]

# Создаем папки и файлы
for i in range(1, 26):
	folder_name = f"{i:03d}"
	os.makedirs(folder_name, exist_ok=True)

	for j in range(1, 26):
		file_name = f"{folder_name}_{j:03d}.json"
		file_path = os.path.join(folder_name, file_name)
		with open(file_path, 'w', encoding='utf-8') as f:
			json.dump(data_template, f, indent=4, ensure_ascii=False)

print("Папки и JSON файлы созданы успешно!")
