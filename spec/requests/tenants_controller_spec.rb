# frozen_string_literal: true

describe V1::TenantsController do
  let!(:tenant) { create :tenant }

  describe 'GET /v1/tenants' do
    let(:url) { v1_tenants_url }

    context 'with auth' do
      let(:admin) { create :admin, :admin, tenant: }

      sign_in :admin

      it 'retrives a list of all existing tenants records' do
        get url
        # status code expectations
        expect(response).to have_http_status(:ok)
        # data expectations
        tenants_data = json['tenants']
        tenant_data = tenants_data.first
        expect(tenants_data.count).to eq(1)
        expect(tenant_data['id']).to eq(tenant.id)
        expect(tenant_data['name']).to eq(tenant.name)
        expect(tenant_data['created_at']).to be_present
        expect(tenant_data['updated_at']).to be_present
      end

      it 'retrives a list of filtered by date tenant records' do
        # create invalid record
        current_time = Time.current
        create(:tenant, created_at: current_time.advance(days: -2))
        params = {
          start_date: current_time.advance(days: -1),
          end_date: current_time
        }
        get(url, params:)
        # status code expectations
        expect(response).to have_http_status(:ok)
        # data expectations
        tenants_data = json['tenants']
        expect(tenants_data.count).to eq(1)
      end
    end

    context 'without auth' do
      it 'returns unauthorized' do
        current_time = Time.current
        params = {
          start_date: current_time.advance(days: -1),
          end_date: current_time
        }
        get(url, params:)
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'GET /v1/tenants/:id' do
    let!(:url) { v1_tenant_url(tenant.id) }

    context 'with admin auth' do
      let(:admin) { create :admin, :admin, tenant: }

      sign_in :admin

      it 'returns a [Tenant] resource' do
        get url
        # status code expectations
        expect(response).to have_http_status(:ok)
        # data expectations
        tenant_data = json['tenant']
        expect(tenant_data['id']).to eq(tenant.id)
        expect(tenant_data['name']).to eq(tenant.name)
      end

      it 'does not return a [Tenant] resource with invalid id' do
        url = v1_tenant_url(0)
        get url
        # status code expectations
        expect(response).to have_http_status(:not_found)
      end
    end

    context 'without auth' do
      it 'returns unauthorized' do
        get url
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'PUT /v1/tenants/:id' do
    let!(:url) { v1_tenant_url(tenant.id) }

    context 'with admin auth' do
      let!(:params) do
        attributes_for(:tenant)
      end

      let(:admin) { create :admin, :admin, tenant: }

      sign_in :admin

      it 'updates a [Tenant] resource' do
        put url, params: { tenant: params }
        # status code expectations
        expect(response).to have_http_status(:ok)
        # data expectations
        tenant_data = json['tenant']
        expect(tenant_data['id']).to eq(tenant.id)
        expect(tenant_data['name']).to eq(params[:name])
      end

      it 'does not update a [Tenant] resource with params' do
        # set invalid name
        params[:name] = nil
        put url, params: { tenant: params }
        # status code expectations
        expect(response).to have_http_status(:unprocessable_entity)
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
