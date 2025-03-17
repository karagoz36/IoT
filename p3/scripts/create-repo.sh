#!/bin/bash

# Renk kodları
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Çalışma dizinini belirle
REPO_DIR="/tmp/iot-p3/p3-repo"

# .env dosyasından token'ı oku
if [ -f .env ]; then
  source .env
  if [ -z "$GITHUB_TOKEN" ]; then
    echo -e "${RED}GITHUB_TOKEN .env dosyasında tanımlı değil!${NC}"
    exit 1
  fi
else
  echo -e "${RED}.env dosyası bulunamadı!${NC}"
  echo -e "${YELLOW}Lütfen şu komutu çalıştırın:${NC}"
  echo 'echo "GITHUB_TOKEN=your_token" > .env'
  exit 1
fi

echo -e "${YELLOW}GitHub reposu oluşturuluyor...${NC}"

cd $REPO_DIR
git init
git add .
git commit -m "İlk commit: v1 deploymentı"

# Eğer remote zaten varsa kaldır
git remote remove origin 2>/dev/null

# Token kullanarak yeni remote ekle
git remote add origin https://karagoz36:${GITHUB_TOKEN}@github.com/karagoz36/IoT_scripts.git

echo -e "${YELLOW}Dosyalar GitHub'a push ediliyor...${NC}"
git push -u origin master

if [ $? -eq 0 ]; then
  echo -e "${GREEN}Repository başarıyla oluşturuldu ve dosyalar push edildi.${NC}"
  echo -e "${YELLOW}ArgoCD otomatik olarak repository'yi izlemeye başlayacak.${NC}"
else
  echo -e "${RED}Repository oluşturma veya push işlemi başarısız oldu.${NC}"
  echo "Lütfen GitHub repository'nizin varlığını ve token'ın geçerliliğini kontrol edin."
fi