import requests
import json

url = "https://openrouter.ai/api/v1/chat/completions"
headers = {
    "Authorization": "Bearer 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",
    "Content-Type": "application/json"
}
data = {
    "model": "amazon/nova-2-lite-v1:free",
    "messages": [
        {"role": "user", "content": "Hello"}
    ]
}

try:
    response = requests.post(url, headers=headers, json=data)
    print(f"Status Code: {response.status_code}")
    print(f"Response Body: {response.text}")
except Exception as e:
    print(f"Error: {e}")
