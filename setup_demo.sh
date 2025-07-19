#!/bin/bash

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🚀 Configurando FoamAI Demo Environment${NC}"
echo -e "${BLUE}======================================${NC}"

# Verificar que estamos en el directorio correcto
if [ ! -f "Gemfile" ]; then
    echo -e "${RED}❌ Error: No se encontró Gemfile. Asegúrate de estar en el directorio raíz del proyecto.${NC}"
    exit 1
fi

# Verificar variables de entorno
echo -e "${YELLOW}📋 Verificando variables de entorno...${NC}"
if [ -z "$DATABASE_URL" ] && [ ! -f ".env" ]; then
    echo -e "${YELLOW}⚠️  No se encontraron variables de entorno configuradas.${NC}"
    echo -e "${YELLOW}   Asegúrate de tener configuradas las siguientes variables:${NC}"
    echo -e "${YELLOW}   - DATABASE_URL${NC}"
    echo -e "${YELLOW}   - OPENAI_API_KEY (si usas OpenAI)${NC}"
    echo -e "${YELLOW}   - Otras variables específicas de tu aplicación${NC}"
    echo ""
    read -p "¿Deseas continuar de todos modos? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# Instalar dependencias
echo -e "${BLUE}📦 Instalando dependencias...${NC}"
bundle install

if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Error instalando dependencias. Verifica tu Gemfile.${NC}"
    exit 1
fi

# Configurar base de datos
echo -e "${BLUE}🗄️  Configurando base de datos...${NC}"
rails db:create
rails db:migrate

if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Error configurando la base de datos.${NC}"
    exit 1
fi

# Ejecutar seeds si existen
if [ -f "db/seeds.rb" ] && [ -s "db/seeds.rb" ]; then
    echo -e "${BLUE}🌱 Ejecutando seeds...${NC}"
    rails db:seed
fi

# Crear datos de demo usando FactoryBot
echo -e "${BLUE}🤖 Creando datos de demo...${NC}"
cat > tmp/setup_demo_data.rb << 'EOF'
# Script para crear datos de demo
puts "Creando tenant de demo..."
tenant = FactoryBot.create(:tenant)
puts "✅ Tenant creado: #{tenant.name} (ID: #{tenant.id})"

puts "Creando API Key..."
api_key = FactoryBot.create(:api_key, tenant: tenant, role: ApiKey::Role.all)
puts "✅ API Key creado: #{api_key.api_key}"

puts "Creando bot de demo..."
bot = FactoryBot.create(:bot, 
  custom_instructions: "Solo responde al usuario.", 
  name: "Let's Talk", 
  whatsapp_phone: "14157386102", 
  tenant: tenant
)
puts "✅ Bot creado: #{bot.name} (ID: #{bot.id})"

# Guardar información para mostrar al usuario
File.write("tmp/demo_credentials.txt", <<~CREDENTIALS
API_KEY=#{api_key.api_key}
BOT_ID=#{bot.id}
TENANT_ID=#{tenant.id}
CREDENTIALS
)

puts ""
puts "🎉 ¡Configuración completada!"
puts "📋 Credenciales guardadas en tmp/demo_credentials.txt"
EOF

# Ejecutar el script de creación de datos
rails runner tmp/setup_demo_data.rb

if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Error creando datos de demo. Verifica que FactoryBot esté configurado correctamente.${NC}"
    exit 1
fi

# Leer las credenciales generadas
if [ -f "tmp/demo_credentials.txt" ]; then
    source tmp/demo_credentials.txt
    echo -e "${GREEN}✅ Datos de demo creados exitosamente!${NC}"
    echo -e "${GREEN}======================================${NC}"
    echo -e "${GREEN}📋 CREDENCIALES DE DEMO:${NC}"
    echo -e "${BLUE}   API Key: ${YELLOW}$API_KEY${NC}"
    echo -e "${BLUE}   Bot ID:  ${YELLOW}$BOT_ID${NC}"
    echo -e "${BLUE}   Tenant:  ${YELLOW}$TENANT_ID${NC}"
    echo -e "${GREEN}======================================${NC}"
else
    echo -e "${RED}❌ No se pudieron leer las credenciales generadas.${NC}"
    exit 1
fi

echo ""
echo -e "${BLUE}🌐 Iniciando servidor Rails...${NC}"
echo -e "${GREEN}📱 Una vez que el servidor esté corriendo, visita:${NC}"
echo -e "${YELLOW}   http://localhost:3000/chat.html${NC}"
echo ""
echo -e "${GREEN}💡 Usa las credenciales mostradas arriba para configurar tu chat.${NC}"
echo -e "${BLUE}   Presiona Ctrl+C para detener el servidor cuando termines.${NC}"
echo ""

# Limpiar archivo temporal
rm -f tmp/setup_demo_data.rb

# Iniciar el servidor Rails
rails server
