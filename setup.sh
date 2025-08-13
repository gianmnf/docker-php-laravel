#!/bin/bash

echo "🚀 Configurando ambiente Laravel com Docker..."

mkdir -p docker/mysql
mkdir -p docker/apache/sites-available
mkdir -p storage/logs

echo "🐳 Iniciando containers..."
docker-compose up -d --build

echo "⏳ Aguardando MySQL inicializar..."
sleep 30

if [ -f "composer.json" ]; then
    echo "📦 Instalando dependências do Composer..."
    docker-compose exec app composer install

    if [ ! -f ".env" ]; then
        echo "📝 Criando arquivo .env..."
        cp .env.example .env
        docker-compose exec app php artisan key:generate
    fi
    
    echo "🗃️ Executando migrations..."
    docker-compose exec app php artisan migrate
    
    echo "🔗 Criando link para storage..."
    docker-compose exec app php artisan storage:link
    
    echo "🧹 Limpando cache..."
    docker-compose exec app php artisan config:clear
    docker-compose exec app php artisan cache:clear
    docker-compose exec app php artisan view:clear

    if [ -f "package.json" ]; then
        echo "📦 Instalando dependências NPM..."
        docker-compose exec node npm install
    fi
else
    echo "📋 Para criar um novo projeto Laravel, execute:"
    echo "docker-compose exec app composer create-project laravel/laravel . --prefer-dist"
fi

echo "✅ Ambiente configurado com sucesso!"
echo ""
echo "🌐 Serviços disponíveis:"/
echo "  - Aplicação Laravel: http://localhost:8800"
echo "  - phpMyAdmin: http://localhost:8088/"
echo "  - Mailhog: http://localhost:8025/"
echo "  - MySQL: http://localhost:3307"
echo ""
echo "📚 Comandos úteis:"
echo "  - Acessar container da aplicação: docker-compose exec app bash"
echo "  - Acessar container Node.js: docker-compose exec node sh"
echo "  - Ver logs: docker-compose logs -f app"
echo "  - Parar containers: docker-compose down"
echo "  - Rebuild containers: docker-compose up -d --build"