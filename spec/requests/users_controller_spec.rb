# frozen_string_literal: true

describe V1::UsersController do
  let(:admin) { create :admin, :admin }

  describe 'POST /v1/sign_in' do
    let(:user) { create :user }
    let(:password) { 'notas3cret' }
    let(:params) do
      {
        email: user.email,
        password:
      }
    end
    let(:url) { v1_user_session_url }

    before do
      user.update! password:, password_confirmation: password
    end

    it 'authenticates a valid user' do
      # chrome browser
      headers = {
        'user-agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_6) ' \
                      'AppleWebKit/537.36 (KHTML, like Gecko) ' \
                      'Chrome/85.0.4183.121 Safari/537.36'
      }
      post(url, params:, headers:)
      # status code expectations
      expect(response).to have_http_status(:ok)
      # data expectations
      user_data = json['user']
      expect(user_data['id']).to eq(user.id)
      expect(user_data['email']).to eq(user.email)
      expect(user_data['name']).to eq(user.name)
      expect(user_data['last_name']).to eq(user.last_name)
      expect(user_data['email']).to eq(user.uid)
    end
  end

  describe 'POST /password' do
    let(:user) { create :user }
    let!(:url) { v1_user_password_url }

    before do
      user.update! email: 'giovanni@guruteconecta.com'
    end

    it 'generates a password recovery token for a valid user' do
      # expect to send email with valid params
      expect(ApplicationMailer)
        .to receive(:reset_password_instructions)
        .once
        .and_call_original
      VCR.use_cassette(
        'reset_password_instructions_ses_user',
        match_requests_on: [:ses_api]
      ) do
        post url, params: { email: user.email }
      end
      # status code expectations
      expect(response).to have_http_status(:ok)
      # data expectations
      user.reload
      expect(user.reset_password_token).to be_present
      expect(user.reset_password_sent_at).to be_present
    end

    it 'generates a password recovery token for a valid user and expired ' \
       'password update' do
      # expect to send email with valid params
      expect(ApplicationMailer)
        .to receive(:reset_password_instructions)
        .once
        .and_call_original
      expired_token = 'xxx'
      user.update!(
        reset_password_token: expired_token,
        reset_password_sent_at: Time.current.advance(days: -1)
      )
      # freeze time for expiry validation
      Timecop.freeze(Time.current) do
        VCR.use_cassette(
          'reset_password_instructions_ses_user',
          match_requests_on: [:ses_api]
        ) do
          post url, params: { email: user.email }
        end
      end
      # status code expectations
      expect(response).to have_http_status(:ok)
      # data expectatio
      user.reload
      expect(user.reset_password_token).not_to eq(expired_token)
      expect(user.reset_password_sent_at).to be_present
    end

    it 'does not generate a password recovery token for an pending password ' \
       'recovery user' do
      user.update!(
        reset_password_token: 'xxx',
        reset_password_sent_at: Time.zone.now
      )
      VCR.use_cassette(
        'reset_password_instructions_ses_user',
        match_requests_on: [:ses_api]
      ) do
        post url, params: { email: user.email }
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

  describe 'GET /v1/users' do
    let!(:url) { v1_users_url }

    context 'with auth' do
      let!(:user) { create :user, tenant: admin.tenant }

      sign_in :admin

      it 'retrives a list of all existing user records' do
        get url
        # status code expectations
        expect(response).to have_http_status(:ok)
        # data expectations
        users_data = json['users']
        user_data = users_data.first
        expect(users_data.count).to eq(1)
        expect(user_data['id']).to eq(user.id)
        expect(user_data['name']).to eq(user.name)
        expect(user_data['last_name']).to eq(user.last_name)
        expect(user_data['email']).to eq(user.email)
        expect(user_data['created_at']).to be_present
        expect(user_data['updated_at']).to be_present
      end

      it 'retrives a list of filtered by date users records' do
        # create invalid record
        current_time = Time.current
        create(:user, tenant: user.tenant,
                      created_at: current_time.advance(days: -2))
        params = {
          start_date: current_time.advance(days: -1),
          end_date: current_time
        }
        get(url, params:)
        expect(response).to have_http_status(:ok)
        expect(json['users'].count).to eq(1)
      end

      it 'skips pagination by sending params[:paginate] = false' do
        # set pagination params
        params = { paginate: false }
        # request
        get(url, params:)
        # status code expectations
        expect(response).to have_http_status(:ok)
        # data expectations
        users_data = json['users']
        expect(users_data.count).to eq(1)
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
        users_data = json['users']
        expect(users_data.count).to eq(1)
        expect(users_data.map { |a| a['id'] }).to include(user.id)
      end
    end

    context 'without auth' do
      it 'shouldnt retrive a list of user records and return unauthorized' do
        get url
        expect(response).to have_http_status(:unauthorized)
      end

      it 'shouldnt return filtered users and return unauthorized' do
        current_time = Time.current
        params = {
          start_date: current_time.advance(days: -1),
          end_date: current_time
        }
        get(url, params:)
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'with filter' do
      let(:user) do
        create :user, tenant: admin.tenant
      end

      sign_in :admin

      it 'lists a collection of [User] elements filtered by name' do
        # create eligible record
        record = create(:user, tenant: admin.tenant, name: 'Dino')
        # http request
        get url, params: { globalSearch: 'Dino' }
        # status code expectations
        expect(response).to have_http_status(:ok)
        # data expectations
        users = json['users']
        expect(users.length).to eq(1)
        user_data = users.first
        expect(user_data['id']).to eq(record.id)
      end
    end
  end

  describe 'POST /v1/users' do
    let!(:url) { v1_users_url }

    context 'with auth' do
      sign_in :admin

      let!(:params) { attributes_for(:user) }

      it 'creates a new user with the given params' do
        post url, params: {
          user: params,
          tenant_id: admin.tenant.id
        }
        expect(response).to have_http_status(:created)
        user_data = json['user']
        expect(user_data['name']).to eq(params[:name])
        expect(user_data['last_name']).to eq(params[:last_name])
        expect(user_data['email']).to eq(params[:email])
      end

      it 'returns unprocessable_entity status with invalid params' do
        post url, params: {
          user: { name: '' },
          tenant_id: admin.tenant.id
        }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe 'GET /v1/users/:id' do
    let!(:record) do
      create(:user, tenant: admin.tenant)
    end

    let!(:url) { v1_user_url(record.id) }

    context 'with auth' do
      sign_in :admin

      it 'returns user by id' do
        get url
        expect(response).to have_http_status(:ok)
        # data expectations
        user_data = json['user']
        expect(user_data['name']).to eq(record.name)
        expect(user_data['last_name']).to eq(record.last_name)
        expect(user_data['email']).to eq(record.email)
        expect(user_data['password']).to be_nil
        expect(user_data['password_confirmation']).to be_nil
      end
    end

    context 'without auth' do
      it 'returns unauthorized' do
        get url
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'PUT /v1/users/:id' do
    let!(:record) { create(:user, tenant: admin.tenant) }

    let!(:url) { v1_user_url(record.id) }
    let!(:params) { attributes_for(:user) }

    context 'with auth' do
      sign_in :admin

      it 'updates an user with the given params' do
        put url, params: { user: params }
        expect(response).to have_http_status(:ok)
        # data expectations
        user_data = json['user']
        expect(user_data['name']).to eq(params[:name])
        expect(user_data['last_name']).to eq(params[:last_name])
        expect(user_data['password']).to be_nil
        expect(user_data['password_confirmation']).to be_nil
      end
    end

    context 'without auth' do
      it 'returns unauthorized' do
        put url, params: { user: params }
        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe 'DELETE /users/:id' do
    let!(:user) { create :user, tenant: admin.tenant }
    let!(:url) { v1_user_url(user.id) }

    context 'with auth' do
      sign_in :admin

      it 'deletes a [User] element' do
        delete url
        # status code expectations
        expect(response).to have_http_status(:ok)
        # data expectations
        user_data = json['user']
        expect(user_data['id']).to eq(user.id)
        expect(User.last).to be_nil
      end

      it 'does not delete a [User] with invalid :id' do
        url = v1_user_url('invalid')
        delete url
        # status code expectations
        expect(response).to have_http_status(:not_found)
      end
    end

    context 'without auth' do
      let!(:url) { v1_user_url('invalid') }

      it 'returns unauthorized' do
        delete url
        # status code expectations
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'GET /v1/validate_token' do
    let!(:user) { create :user, tenant: admin.tenant }
    let!(:url) { users_validate_token_url }

    context 'with auth' do
      sign_in :user

      it 'validates a token' do
        get url
        # status code expectations
        expect(response).to have_http_status(:ok)
        # data expectations
        user_data = json['user']
        # user data expectations
        expect(user_data['id']).to eq(user.id)
        expect(user_data['name']).to be_present
        expect(user_data['last_name']).to be_present
        expect(user_data['email']).to be_present
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
