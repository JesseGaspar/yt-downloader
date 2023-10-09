from google.oauth2.service_account import Credentials
from googleapiclient.discovery import build
from googleapiclient.http import MediaFileUpload
from googleapiclient.errors import HttpError
import sys
import os

MAX_RETRIES = 3  # Limite máximo de retentativas de upload

def upload_video(credentials_path, video_path, title, description, tags):
    # Verificar se o vídeo já existe antes de fazer upload
    if os.path.exists(f"{title}.uploaded"):
        print(f"O vídeo {title} já foi enviado.")
        return

    print(f"Fazendo upload de {video_path} com título: {title}, descrição: {description}, tags: {tags}")
  
    # Carregar credenciais
    credentials = Credentials.from_service_account_file(credentials_path, scopes=["https://www.googleapis.com/auth/youtube.upload"])

    # Criar cliente da API do YouTube
    youtube = build('youtube', 'v3', credentials=credentials)

    # Validar e limpar as tags
    tags = [tag.strip() for tag in tags.split(",") if tag.strip()]

    # Configurações do vídeo
    body = {
        'snippet': {
            'title': title,
            'description': description,
            'tags': tags,
            'categoryId': '22'
        },
        'status': {
            'privacyStatus': 'unlisted'
        }
    }

    # Fazer upload do vídeo
    media = MediaFileUpload(video_path, chunksize=5*1024*1024, resumable=True, mimetype='video/*')
    request = youtube.videos().insert(
        part="snippet,status",
        body=body,
        media_body=media
    )

    retries = 0  # Contador de retentativas
    response = None
    try:
        while response is None and retries < MAX_RETRIES:
            print(f"Tentativa de upload {retries + 1}...")
            status, response = request.next_chunk()
            if response is not None:
                if 'id' in response:
                    print(f"Vídeo foi enviado com sucesso. ID: {response['id']}")
                    # Marcar o vídeo como enviado criando um arquivo vazio
                    open(f"{title}.uploaded", 'a').close()
                else:
                    print("O servidor não retornou um ID de vídeo. Tentando novamente.")
                    retries += 1
    except HttpError as e:
        print(f"Ocorreu um erro HTTP: {e.resp.status}, {e.content}")
        if e.resp.status == 403:
            print("Cota excedida. Saindo.")
            exit(1)
    except Exception as e:
        print(f"Ocorreu um erro desconhecido: {e}")

if __name__ == "__main__":
    credentials_path = sys.argv[1]
    video_path = sys.argv[2]
    title = sys.argv[3]
    description = sys.argv[4]
    tags = sys.argv[5]  # As tags serão divididas e limpas na função upload_video
    upload_video(credentials_path, video_path, title, description, tags)
