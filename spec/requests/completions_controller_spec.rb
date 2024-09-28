# frozen_string_literal: true

describe V1::CompletionsController do
  let!(:tenant) { create :tenant }
  let!(:bot) do
    create :bot, tenant:
  end

  describe 'GET /v1/completions' do
    let!(:url) { v1_completions_url }

    context 'with admin auth' do
      let!(:completion) do
        create :completion, bot:
      end

      let(:admin) { create :admin, :admin, tenant: }

      sign_in :admin

      it 'list of all existing records' do
        get url
        # status code expectations
        expect(response).to have_http_status(:ok)
        # data code expectations
        completions_data = json['completions']
        completion_data = completions_data.first
        expect(completions_data.count).to eq(1)
        expect(completion_data['id']).to eq(completion.id)
        expect(completion_data['status'])
          .to eq(Completion::Status::VALID_RESPONSE.to_s)
        expect(completion_data['prompt']).to be_present
        expect(completion_data['response']).to be_present
        expect(completion_data['created_at']).to be_present
        expect(completion_data['updated_at']).to be_present
      end
    end

    context 'with api_key auth' do
      let!(:completion) do
        create :completion, bot:
      end

      let(:api_key) { create :api_key, :completions, tenant: }

      sign_in :api_key

      it 'list of all existing records' do
        get url
        # status code expectations
        expect(response).to have_http_status(:ok)
        # data code expectations
        completions_data = json['completions']
        completion_data = completions_data.first
        expect(completions_data.count).to eq(1)
        expect(completion_data['id']).to eq(completion.id)
        expect(completion_data['status'])
          .to eq(Completion::Status::VALID_RESPONSE.to_s)
        expect(completion_data['prompt']).to be_present
        expect(completion_data['response']).to be_present
        expect(completion_data['created_at']).to be_present
        expect(completion_data['updated_at']).to be_present
      end
    end
  end

  describe 'GET /v1/completions/:id' do
    let!(:completion) do
      create :completion, bot:
    end

    let!(:url) { v1_completion_url(completion.id) }

    context 'with admin auth' do
      let(:admin) { create :admin, :admin, tenant: }

      sign_in :admin

      it 'returns completion by id' do
        get url
        expect(response).to have_http_status(:ok)
        # data expectations
        completion_data = json['completion']
        expect(completion_data['id']).to eq(completion.id)
        expect(completion_data['status'])
          .to eq(Completion::Status::VALID_RESPONSE.to_s)
        expect(completion_data['prompt']).to be_present
        expect(completion_data['response']).to be_present
        expect(completion_data['created_at']).to be_present
        expect(completion_data['updated_at']).to be_present
      end
    end

    context 'with api_key auth' do
      let(:api_key) { create :api_key, :completions, tenant: }

      sign_in :api_key

      it 'list of all existing records' do
        get url
        # status code expectations
        expect(response).to have_http_status(:ok)
        # data code expectations
        completion_data = json['completion']
        expect(completion_data['id']).to eq(completion.id)
        expect(completion_data['status'])
          .to eq(Completion::Status::VALID_RESPONSE.to_s)
        expect(completion_data['prompt']).to be_present
        expect(completion_data['response']).to be_present
        expect(completion_data['created_at']).to be_present
        expect(completion_data['updated_at']).to be_present
      end
    end

    context 'without auth' do
      it 'returns unauthorized' do
        get url
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'POST /v1/completions' do
    let!(:url) { v1_completions_url }

    context 'with admin auth' do
      let(:admin) { create :admin, :admin, tenant: }

      let!(:params) do
        {
          prompt: 'Hola',
          bot_id: bot.id
        }
      end

      sign_in :admin

      it 'creates a new user with the given params' do
        VCR.use_cassette(
          'completion_text_interaction',
          match_requests_on: [:host]
        ) do
          post url, params: { completion: params }
        end
        expect(response).to have_http_status(:created)
        # data expectations
        completion_data = json['completion']
        expect(completion_data['prompt']).to eq(params[:prompt])
        expect(completion_data['bot_id']).to eq(params[:bot_id])
        expect(completion_data['response']).to be_present
        expect(completion_data['status']).to eq(
          Completion::Status::VALID_RESPONSE.to_s
        )
      end
    end

    context 'with api_key auth' do
      let(:api_key) { create :api_key, :completions, tenant: }

      let!(:params) do
        {
          prompt: 'Hola',
          bot_id: bot.id
        }
      end

      sign_in :api_key

      it 'creates a new user with the given params' do
        VCR.use_cassette(
          'completion_text_interaction',
          match_requests_on: [:host]
        ) do
          post url, params: { completion: params }
        end
        expect(response).to have_http_status(:created)
        # data expectations
        completion_data = json['completion']
        expect(completion_data['prompt']).to eq(params[:prompt])
        expect(completion_data['bot_id']).to eq(params[:bot_id])
        expect(completion_data['response']).to be_present
        expect(completion_data['status']).to eq(
          Completion::Status::VALID_RESPONSE.to_s
        )
      end
    end

    context 'without auth' do
      it 'returns unauthorized' do
        post url, params: { completion: {} }
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
