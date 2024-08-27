# frozen_string_literal: true

describe V1::ApiKeysController do
  let!(:tenant) { create :tenant }

  describe 'GET /v1/api_keys' do
    let!(:url) { v1_api_keys_url }
    let!(:api_key) { create :api_key, tenant: }

    context 'with admin auth' do
      let(:admin) { create :admin, :admin, tenant: }

      sign_in :admin

      it 'retrives a list of all existing api_keys records' do
        get url
        # status code expectations
        expect(response).to have_http_status(:ok)
        # data code expectations
        api_keys_data = json['api_keys']
        api_key_data = api_keys_data.first
        expect(api_keys_data.count).to eq(1)
        expect(api_key_data['id']).to eq(api_key.id)
        expect(api_key_data['name']).to eq(api_key.name)
        expect(api_key_data['role']).to eq(api_key.role)
        expect(api_key_data['created_at']).to be_present
        expect(api_key_data['updated_at']).to be_present
      end

      it 'retrives a list of filtered by date' do
        # creates inelegible record
        current_time = Time.current
        create :api_key, tenant:, created_at: current_time.advance(days: -5)
        params = {
          start_date: current_time.advance(days: -1),
          end_data: current_time
        }
        # request
        get(url, params:)
        # status code expecteations
        expect(response).to have_http_status(:ok)
        # data expectations
        api_keys_data = json['api_keys']
        expect(api_keys_data.count).to eq(1)
      end
    end

    context 'without auth' do
      it 'returns unauthorized' do
        get url
        # status code expectations
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'POST /v1/api_keys' do
    let!(:url) { v1_api_keys_url }
    let!(:params) do
      attributes_for(:api_key)
    end

    context 'with admin auth' do
      let(:admin) { create :admin, :admin, tenant: }

      sign_in :admin

      it 'creates a [ApiKey]' do
        post url, params: { api_key: params }
        # status code expectations
        expect(response).to have_http_status(:created)
        # data expectations
        api_key_data = json['api_key']
        expect(api_key_data['name']).to eq(params[:name])
        expect(api_key_data['role']).to eq(params[:role])
      end

      it 'does not create with invalid params' do
        # invalid params
        params[:name] = ''
        post url, params: { api_key: params }
        # status code expectations
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context 'without auth' do
      it 'returns unauthorized' do
        post url
        # status code expectations
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'GET /v1/api_keys/:id' do
    let!(:api_key) { create :api_key, tenant: }
    let!(:url) { v1_api_key_url(api_key.id) }

    context 'with admin auth' do
      let(:admin) { create :admin, :admin, tenant: }

      sign_in :admin

      it 'returns a [ApiKey] resource' do
        get url
        # status code expectations
        expect(response).to have_http_status(:ok)
        # data expectations
        api_key_data = json['api_key']
        expect(api_key_data['id']).to eq(api_key.id)
        expect(api_key_data['name']).to eq(api_key.name)
        expect(api_key_data['role']).to eq(api_key.role)
        expect(api_key_data['api_key']).to eq(api_key.api_key)
        expect(api_key_data['created_at']).to be_present
        expect(api_key_data['updated_at']).to be_present
      end

      it 'does not get an invalid id' do
        get v1_api_key_url 'INVALID'
        # status code expectations
        expect(response).to have_http_status(:not_found)
      end
    end

    context 'without auth' do
      it 'returns unauthorized' do
        get url
        # status code expectations
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'PUT /v1/api_keys/:id' do
    let!(:api_key) { create :api_key, tenant: }
    let!(:url) { v1_api_key_url(api_key.id) }
    let!(:params) do
      attributes_for(:api_key)
    end

    context 'with admin auth' do
      let(:admin) { create :admin, :admin, tenant: }

      sign_in :admin

      it 'updates an [ApiKey]' do
        put url, params: { api_key: params }
        # status code expectations
        expect(response).to have_http_status(:ok)
        # data expectations
        api_key_data = json['api_key']
        expect(api_key_data['name']).to eq(params[:name])
        expect(api_key_data['role']).to eq(params[:role])
        expect(api_key_data['created_at']).to be_present
        expect(api_key_data['updated_at']).to be_present
      end

      it 'does not update an [ApiKey] with invalid params' do
        params[:name] = nil
        put url, params: { api_key: params }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context 'without auth' do
      it 'returns unauthorized' do
        put url
        # status code expectations
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'DELETE /api_keys/:id' do
    let!(:url) { v1_api_key_url(api_key.id) }
    let!(:api_key) { create :api_key, tenant: }

    context 'with admin auth' do
      let(:admin) { create :admin, :admin, tenant: }

      sign_in :admin

      it 'deletes a [ApiKey] element with valid :id param' do
        delete url
        # status code expectations
        expect(response).to have_http_status(:ok)
        # data expectations
        api_key_data = json['api_key']
        expect(api_key_data).to be_present
        expect(ApiKey.last).to be_nil
      end

      it 'does not delete an element with invalid id' do
        delete v1_api_key_url 'INVALID'
        # status code expectations
        expect(response).to have_http_status(:not_found)
      end
    end

    context 'without auth' do
      it 'returns unauthorized' do
        delete url
        # status code expectations
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
