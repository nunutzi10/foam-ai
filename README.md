# 🤖 FoamAI - Custom AI Chatbot Platform

FoamAI is a simple yet powerful platform that allows you to create custom AI chatbots with personalized instructions. You can build bots with specific personalities, knowledge, and behaviors, then chat with them through a clean web interface.

## ✨ What does this project do?

- **Create Custom Bots**: Build AI chatbots with custom instructions and personalities
- **Chat Interface**: Simple web interface to interact with your bots
- **Multi-tenant Support**: Multiple organizations can have their own bots and users
- **API Integration**: Uses OpenAI's GPT models for intelligent conversations
- **WhatsApp Integration**: Connect your bots to WhatsApp for broader reach

Perfect for:
- Building customer support bots
- Creating educational assistants  
- Developing entertainment chatbots
- Prototyping conversational AI ideas

## 🚀 Quick Demo (Recommended)

The easiest way to try FoamAI is using our automated setup script:

```bash
./setup_demo.sh
```

This script will:
1. Install all dependencies
2. Set up the database
3. Create a demo bot named "Let's Talk" 
4. Generate API credentials
5. Start the server at `http://localhost:3000/chat.html`

**That's it!** You'll be chatting with your bot in under 2 minutes.

## 🛠️ Manual Setup (Step by Step)

If you prefer to set up everything manually or want to understand the process:

### Prerequisites

- **Ruby 3.1.2** (we recommend using [RVM](http://rvm.io/))
- **PostgreSQL** database
- **Git**
- **OpenAI API Key** (get one at [OpenAI Platform](https://platform.openai.com/))

### Step 1: Clone and Install Dependencies

```bash
git clone <repository-url>
cd foam-ai
bundle install
```

### Step 2: Configure Environment Variables

Create a `.env` file in the root directory:

```bash
# Database Configuration
DATABASE_URL=postgresql://username:password@localhost/foam_ai_development

# OpenAI Configuration  
OPENAI_API_KEY=your_openai_api_key_here

# Optional: Other configurations
RAILS_ENV=development
```

### Step 3: Set Up Database

```bash
rails db:create
rails db:migrate
rails db:seed  # Optional: if you have seed data
```

### Step 4: Create Demo Data

Open Rails console and run these commands:

```ruby
# Create a tenant (organization)
tenant = FactoryBot.create(:tenant)

# Create API key with full permissions
api_key = FactoryBot.create(:api_key, tenant: tenant, role: ApiKey::Role.all)

# Create your first bot
bot = FactoryBot.create(:bot, 
  custom_instructions: "Solo responde al usuario.", 
  name: "Let's Talk", 
  whatsapp_phone: "14157386102", 
  tenant: tenant
)

# Display your credentials
puts "API Key: #{api_key.api_key}"
puts "Bot ID: #{bot.id}"
puts "Tenant ID: #{tenant.id}"
```

### Step 5: Start the Server

```bash
rails server
```

Visit `http://localhost:3000/chat.html` and use your generated credentials to start chatting!

## 🔧 Technologies Used

This project is built with modern, reliable technologies:

### Backend
- **Ruby on Rails 7.0.6** - Web application framework
- **Ruby 3.1.2** - Programming language
- **PostgreSQL** - Primary database
- **Puma** - Web server

### AI & External Services
- **OpenAI API** - GPT models for intelligent conversations
- **ruby-openai gem** - Ruby client for OpenAI API
- **Vonage** - SMS/WhatsApp integration

### Background Processing & Caching
- **Sidekiq** - Background job processing
- **Redis** - Caching and job queue

### Authentication & Authorization
- **Knock** - JWT-based API authentication
- **Pundit** - Authorization policies

### Development & Testing
- **RSpec** - Testing framework
- **FactoryBot** - Test data generation
- **Parallel Tests** - Faster test execution
- **RuboCop** - Code style checking

### Monitoring & Utilities
- **Airbrake** - Error monitoring
- **Paper Trail** - Model versioning
- **Chronic** - Natural language date parsing

## 📁 Project Structure

```
app/
├── controllers/     # API endpoints and request handling
├── models/         # Data models (Tenant, Bot, Message, etc.)
├── services/       # Business logic and external API calls
├── jobs/           # Background job processing
├── policies/       # Authorization rules
└── serializers/    # JSON response formatting

config/             # Application configuration
db/                # Database migrations and schema
spec/              # Test files and factories
```

## 🤔 How It Works

1. **Tenants**: Organizations that can have multiple bots and users
2. **Bots**: AI assistants with custom instructions and personalities  
3. **Conversations**: Chat sessions between users and bots
4. **Messages**: Individual messages within conversations
5. **API Keys**: Secure authentication for API access

## 🌐 API Endpoints

Once your server is running, you can interact with these endpoints:

- `POST /api/v1/conversations` - Start a new conversation
- `POST /api/v1/conversations/:id/messages` - Send a message
- `GET /api/v1/conversations` - List conversations
- `GET /api/v1/bots` - List available bots

## 🚢 Deployment Options

### Option 1: Traditional Deployment
The application is configured for deployment on platforms like:
- Render
- Heroku  
- AWS
- DigitalOcean

## 🧪 Testing

Run the test suite:
```bash
# Run all tests
rspec spec

# Run specific test file
rspec spec/models/bot_spec.rb

# Check code style
rubocop
```

## 📈 Monitoring & Maintenance

- **Health Checks**: Visit `/health` endpoint
- **Background Jobs**: Monitor Sidekiq dashboard
- **Logs**: Check `log/production.log` for application logs
- **Database**: Regular backups recommended for production

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Make your changes
4. Run tests (`rake parallel:spec`)
5. Commit your changes (`git commit -m 'Add amazing feature'`)
6. Push to the branch (`git push origin feature/amazing-feature`)
7. Open a Pull Request

## 📝 License

This project is available as open source under the terms of the MIT License.

**Made with ❤️ for the Giovanni**

Ready to build your first AI chatbot? Run `./setup_demo.sh` and start chatting! 🚀
