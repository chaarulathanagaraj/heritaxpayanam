import os
from dotenv import load_dotenv
from langchain_community.document_loaders import TextLoader
from langchain.text_splitter import RecursiveCharacterTextSplitter
from langchain_google_genai import GoogleGenerativeAIEmbeddings
from langchain_community.vectorstores import Chroma

# Load environment variables
load_dotenv()
GOOGLE_API_KEY = os.getenv("GEMINI_API_KEY")

if not GOOGLE_API_KEY:
    raise ValueError("Missing GEMINI_API_KEY in .env")

# Embedding model
embedding = GoogleGenerativeAIEmbeddings(
    model="models/embedding-001",
    google_api_key=GOOGLE_API_KEY
)

# Persistent Chroma DB
VECTOR_DB_DIR = "db"
vectorstore = Chroma(
    embedding_function=embedding,
    persist_directory=VECTOR_DB_DIR
)

# Splitter setup
text_splitter = RecursiveCharacterTextSplitter(chunk_size=500, chunk_overlap=50)

# List of new files
TEXT_DIR = "./tourism"
FILES = [
    "Brihadeeswarar_Temple.txt",
    "Airavateswarar_Temple.txt",
    "Gangaikonda_Cholapuram.txt",
    "Mamallapuram.txt",
    "Nilgiris_Mountain_Railway.txt"
]

# Load and chunk new documents
new_docs = []
for file in FILES:
    loader = TextLoader(os.path.join(TEXT_DIR, file), encoding="utf-8")
    docs = loader.load()
    chunks = text_splitter.split_documents(docs)
    new_docs.extend(chunks)

# Add and persist
vectorstore.add_documents(new_docs)
vectorstore.persist()

print("✅ Successfully added new content to Chroma DB.")
