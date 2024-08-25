# frozen_string_literal: true

# require all ENV var declard in `.env.sample` file
vars = Dotenv.parse('.env.sample')
keys = vars.keys
Dotenv.require_keys(keys)
