# frozen_string_literal: true

describe V1::AdminsController do
  describe 'POST /admins/sign_in' do
    let!(:now) { Time.current }
    let!(:password) { Faker::Internet.password }
    let(:admin) do
      create :admin, password:, password_confirmation: password
    end
    let!(:url) { v1_admin_session_url }
    let!(:params) do
      {
        email: admin.email,
        password:
      }
    end

    it 'authenticates an Admin' do
      Timecop.freeze(now) do
        post(url, params:)
        # status code expectations
        expect(response).to have_http_status(:ok)
        # data expectations
        admin_data = json['admin']
        expect(admin_data['id']).to eq(admin.id)
        expect(admin_data['name']).to eq(admin.name)
        expect(admin_data['last_name']).to eq(admin.last_name)
        expect(admin_data['email']).to eq(admin.email)
        expect(admin_data['role']).to eq(admin.role)
        expect(admin_data['tenant_id']).to eq(admin.tenant_id)
        # expiry expectations
        expiry = response.headers['expiry'].to_i
        expires_at = Time.zone.at(expiry)
        expect(expires_at).to be_within(1.second)
          .of(now + DeviseTokenAuth.token_lifespan)
        # database expectations
        admin.reload
        token = admin.tokens.first.last
        expect(token).to have_key('lifespan_seconds')
      end
    end

    it 'authenticates and remembers an Admin' do
      # set remember_me param
      params[:remember_me] = true
      Timecop.freeze(now) do
        post(url, params:)
        # status code expectations
        expect(response).to have_http_status(:ok)
        # expiry expectations
        expiry = response.headers['expiry'].to_i
        expires_at = Time.zone.at(expiry)
        expect(expires_at).to be_within(1.second).of(now + 1.day)
      end
    end

    it 'does not authenticate an Admin with invalid password' do
      # set invalid password
      params[:password] = 'INVALID'
      post(url, params:)
      # status code expectations
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe 'POST /password' do
    let(:admin) { create :admin, :admin }
    let!(:url) { v1_admin_password_url }

    before do
      admin.update! email: 'giovanni@guruteconecta.com'
    end

    it 'generates a password recovery token for a valid user' do
      # expect to send email with valid params
      expect(ApplicationMailer)
        .to receive(:reset_password_instructions)
        .once
        .and_call_original
      VCR.use_cassette(
        'reset_password_instructions_ses',
        match_requests_on: [:ses_api]
      ) do
        post url, params: { email: admin.email }
      end
      # status code expectations
      expect(response).to have_http_status(:ok)
      # data expectations
      admin.reload
      expect(admin.reset_password_token).to be_present
      expect(admin.reset_password_sent_at).to be_present
    end

    it 'generates a password recovery token for a valid user and expired ' \
       'password update' do
      # expect to send email with valid params
      expect(ApplicationMailer)
        .to receive(:reset_password_instructions)
        .once
        .and_call_original
      expired_token = 'xxx'
      admin.update!(
        reset_password_token: expired_token,
        reset_password_sent_at: Time.current.advance(days: -1)
      )
      # freeze time for expiry validation
      Timecop.freeze(Time.current) do
        VCR.use_cassette(
          'reset_password_instructions_ses',
          match_requests_on: [:ses_api]
        ) do
          post url, params: { email: admin.email }
        end
      end
      # status code expectations
      expect(response).to have_http_status(:ok)
      # data expectatio
      admin.reload
      expect(admin.reset_password_token).not_to eq(expired_token)
      expect(admin.reset_password_sent_at).to be_present
    end

    it 'does not generate a password recovery token for an pending password ' \
       'recovery user' do
      admin.update!(
        reset_password_token: 'xxx',
        reset_password_sent_at: Time.zone.now
      )
      VCR.use_cassette(
        'reset_password_instructions_ses',
        match_requests_on: [:ses_api]
      ) do
        post url, params: { email: admin.email }
      end
      # status code expectations
      expect(response).to have_http_status(:ok)
    end

    it 'does not generate a password recovery token for an invalid user ' \
       'email' do
      post url, params: { email: 'INVALID' }
      # status code expectations
      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'GET /v1/admins' do
    let!(:tenant) { create :tenant }
    let!(:url) { v1_admins_url }
    let!(:record) { create :admin, tenant: }

    context 'with auth' do
      let(:admin) { create :admin, :admin }
      let!(:record) { create :admin, tenant: admin.tenant }

      sign_in :admin

      it 'retrives a list of all existing admin records' do
        get url
        # status code expectations
        expect(response).to have_http_status(:ok)
        # data expectations
        admins_data = json['admins']
        admin_data = admins_data.first
        expect(admins_data.count).to eq(1)
        expect(admin_data['id']).to eq(record.id)
        expect(admin_data['name']).to eq(record.name)
        expect(admin_data['last_name']).to eq(record.last_name)
        expect(admin_data['email']).to eq(record.email)
        expect(admin_data['created_at']).to be_present
        expect(admin_data['updated_at']).to be_present
      end

      it 'retrives a list of filtered by date admins records' do
        # create invalid record
        current_time = Time.current
        create(:admin, tenant: admin.tenant,
                       created_at: current_time.advance(days: -2))
        params = {
          start_date: current_time.advance(days: -1),
          end_date: current_time
        }
        get(url, params:)
        expect(response).to have_http_status(:ok)
        expect(json['admins'].count).to eq(1)
      end

      it 'skips pagination by sending params[:paginate] = false' do
        # set pagination params
        params = { paginate: false }
        # request
        get(url, params:)
        # status code expectations
        expect(response).to have_http_status(:ok)
        # data expectations
        admins_data = json['admins']
        expect(admins_data.count).to eq(1)
        expect(json).not_to have_key('meta')
      end

      it 'includes current user if include_me is true' do
        # set pagination params
        params = { include_me: true }
        # request
        get(url, params:)
        # status code expectations
        expect(response).to have_http_status(:ok)
        # data expectations
        admins_data = json['admins']
        expect(admins_data.count).to eq(2)
        expect(admins_data.map { |a| a['id'] }).to include(admin.id)
      end

      it 'renews auth token' do
        # first request
        now = Time.current
        first_token = nil
        second_token = nil
        Timecop.freeze(now) do
          get url
          first_token = admin.reload.tokens.first.last
        end
        Timecop.freeze(now + 10.minutes) do
          get url
          second_token = admin.reload.tokens.first.last
        end
        # token is renewed on every request
        expect(second_token['expiry']).to be > first_token['expiry']
      end
    end

    context 'with api_key auth' do
      let(:api_key) { create :api_key, :admins, tenant: }

      sign_in :api_key

      it 'retrives a list of all existing admin records' do
        get url
        # status code expectations
        expect(response).to have_http_status(:ok)
        # data expectations
        admins_data = json['admins']
        admin_data = admins_data.last
        expect(admin_data['id']).to eq(record.id)
        expect(admin_data['name']).to eq(record.name)
        expect(admin_data['last_name']).to eq(record.last_name)
        expect(admin_data['email']).to eq(record.email)
        expect(admin_data['created_at']).to be_present
        expect(admin_data['updated_at']).to be_present
      end
    end

    context 'without auth' do
      it 'returns unauthorized' do
        get url
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'POST /v1/admins' do
    let!(:url) { v1_admins_url }

    context 'with admin auth' do
      let!(:tenant) { create :tenant }
      let(:admin) { create :admin, :admin, tenant: }

      let!(:params) do
        {
          name: 'Amaury',
          last_name: 'Fuentes',
          email: 'amaury@gurucomm.mx',
          password: '12345678',
          password_confirmation: '12345678'
        }
      end

      sign_in :admin

      it 'creates a new admin with the given params' do
        post url, params: { admin: params }
        # status code expectations
        expect(response).to have_http_status(:created)
        # data expectations
        admin_data = json['admin']
        expect(admin_data['name']).to eq(params[:name])
        expect(admin_data['last_name']).to eq(params[:last_name])
        expect(admin_data['email']).to eq(params[:email])
        expect(admin_data['password']).to be_nil
        expect(admin_data['password_confirmation']).to be_nil
        expect(admin_data['tenant_id']).to eq(admin.tenant_id)
      end
    end

    context 'with api_key auth' do
      let!(:tenant) { create :tenant }
      let(:api_key) { create :api_key, :admins, tenant: }

      let!(:params) do
        {
          name: 'Amaury',
          last_name: 'Fuentes',
          email: 'amaury@gurucomm.mx',
          password: '12345678',
          password_confirmation: '12345678'
        }
      end

      sign_in :api_key

      it 'creates a new admin with the given params' do
        post url, params: { admin: params }
        expect(response).to have_http_status(:created)
        # data expectations
        admin_data = json['admin']
        expect(admin_data['name']).to eq(params[:name])
        expect(admin_data['last_name']).to eq(params[:last_name])
        expect(admin_data['email']).to eq(params[:email])
        expect(admin_data['password']).to be_nil
        expect(admin_data['password_confirmation']).to be_nil
        expect(admin_data['tenant_id']).to eq(api_key.tenant_id)
      end
    end

    context 'without auth' do
      it 'returns unauthorized' do
        post url
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'GET /v1/admins/:id' do
    let!(:tenant) { create :tenant }
    let(:admin) { create :admin, :admin, tenant: }
    let!(:record) do
      create(:admin, :admin, tenant:)
    end

    let!(:url) { v1_admin_url(record.id) }

    context 'with auth' do
      let(:admin) { create :admin, :admin, tenant: }

      sign_in :admin

      it 'returns admin by id' do
        get url
        expect(response).to have_http_status(:ok)
        # data expectations
        admin_data = json['admin']
        expect(admin_data['name']).to eq(record.name)
        expect(admin_data['last_name']).to eq(record.last_name)
        expect(admin_data['email']).to eq(record.email)
        expect(admin_data['password']).to be_nil
        expect(admin_data['password_confirmation']).to be_nil
      end
    end

    context 'with api_key auth' do
      let!(:tenant) { create :tenant }
      let(:api_key) { create :api_key, :admins, tenant: }

      sign_in :api_key

      it 'retrives a list of all existing admin records' do
        get url
        # status code expectations
        expect(response).to have_http_status(:ok)
        # data expectations
        admin_data = json['admin']
        expect(admin_data['name']).to eq(record.name)
        expect(admin_data['last_name']).to eq(record.last_name)
        expect(admin_data['email']).to eq(record.email)
        expect(admin_data['password']).to be_nil
        expect(admin_data['password_confirmation']).to be_nil
      end
    end

    context 'without auth' do
      it 'returns unauthorized' do
        get url
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'PUT /v1/admins/:id' do
    let!(:tenant) { create :tenant }
    let(:admin) { create :admin, :admin, tenant: }
    let!(:record) { create(:admin, tenant: admin.tenant) }

    let!(:url) { v1_admin_url(record.id) }
    let!(:params) do
      {
        name: 'Amaury',
        last_name: 'Fuentes',
        password: '12345678',
        password_confirmation: '12345678'
      }
    end

    context 'with auth' do
      let(:admin) { create :admin, :admin, tenant: }

      sign_in :admin

      it 'updates an admin with the given params' do
        put url, params: { admin: params }
        expect(response).to have_http_status(:ok)
        # data expectations
        admin_data = json['admin']
        expect(admin_data['name']).to eq(params[:name])
        expect(admin_data['last_name']).to eq(params[:last_name])
        expect(admin_data['password']).to be_nil
        expect(admin_data['password_confirmation']).to be_nil
      end
    end

    context 'with api_key auth' do
      let(:api_key) { create :api_key, :admins, tenant: }
      let!(:record) { create(:admin, tenant: admin.tenant) }

      let!(:url) { v1_admin_url(record.id) }
      let!(:params) do
        {
          name: 'Amaury',
          last_name: 'Fuentes',
          password: '12345678',
          password_confirmation: '12345678'
        }
      end

      sign_in :api_key

      it 'updates an admin with the given params' do
        put url, params: { admin: params }
        expect(response).to have_http_status(:ok)
        # data expectations
        admin_data = json['admin']
        expect(admin_data['name']).to eq(params[:name])
        expect(admin_data['last_name']).to eq(params[:last_name])
        expect(admin_data['password']).to be_nil
        expect(admin_data['password_confirmation']).to be_nil
      end
    end

    context 'without auth' do
      it 'returns unauthorized' do
        put url, params: { admin: params }
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'GET /v1/validate_token' do
    let!(:tenant) { create :tenant }
    let(:admin) { create :admin, :admin, tenant: }
    let!(:url) { v1_admins_validate_token_url }

    context 'with admin auth' do
      sign_in :admin

      it 'validates a token' do
        get url
        # status code expectations
        expect(response).to have_http_status(:ok)
        # data expectations
        admin_data = json['admin']
        # user data expectations
        expect(admin_data['id']).to be_present
        expect(admin_data['name']).to be_present
        expect(admin_data['last_name']).to be_present
        expect(admin_data['email']).to be_present
        expect(admin_data['role']).to be_present
      end
    end

    context 'without auth' do
      it 'returns unauthorized' do
        get url
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
