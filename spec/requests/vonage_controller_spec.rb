# frozen_string_literal: true

describe V1::VonageController do
  let!(:tenant) { create :tenant }

  describe 'POST /vonage/messages' do
    let!(:url) { messages_v1_vonage_index_url }

    context 'without auth' do
      let!(:now) { Time.current }

      let(:mobile) { '524422591631' }

      let!(:bot) { create :bot, tenant: }

      let!(:params) do
        {
          to: bot.whatsapp_phone,
          from: mobile,
          channel: 'whatsapp',
          message_uuid: 'bab86564-99fc-4f96-ad7b-18c1caf0b4e2',
          timestamp: '2023-04-07T21:48:56Z',
          message_type: 'text',
          text: 'test',
          profile: {
            name: 'Giovanni Estrada'
          },
          format: 'json',
          controller: 'v1/vonage',
          action: 'messages',
          vonage: {
            to: bot.whatsapp_phone,
            from: mobile,
            channel: 'whatsapp',
            message_uuid: 'bab86564-99fc-4f96-ad7b-18c1caf0b4e2',
            timestamp: '2023-04-07T21:48:56Z',
            message_type: 'text',
            text: 'test',
            profile: {
              name: 'Giovanni Estrada'
            }
          }
        }
      end

      describe 'unknow [User] interaction' do
        it 'starts the first messages', perform_enqueued: true do
          Timecop.freeze(now) do
            # http request
            VCR.use_cassette(
              'vonage_unknown_interaction',
              match_requests_on: [:vonage_api]
            ) do
              post(url, params:)
            end
            # status code expectations
            expect(response).to have_http_status(:ok)
            # data expectations
            expect(Contact.count).to eq(1)
            # user message
            user_message = Message.user.last
            expect(user_message).to be_sent
            expect(user_message.vonage_id).to be_present
            # system message
            system_message = Message.system.last
            expect(system_message).to be_present
            expect(system_message).to be_sent
            expect(system_message.vonage_id).to be_present
          end
        end
      end

      describe 'reply [User] interaction' do
        it 'creates a new text message', perform_enqueued: true do
          Timecop.freeze(now) do
            contact = create(:contact, phone: mobile, tenant:)
            create(:message, contact:)
            # http request
            VCR.use_cassette(
              'vonage_text_message_interaction',
              match_requests_on: [:host]
            ) do
              post(url, params:)
            end
            # status code expectations
            expect(response).to have_http_status(:ok)
            # data expectations
            expect(Contact.count).to eq(1)
            # user message
            user_message = Message.user.last
            expect(user_message).to be_sent
            expect(user_message.vonage_id).to be_present
            # system message
            system_message = Message.system.last
            expect(system_message).to be_present
            expect(system_message).to be_sent
            expect(system_message.vonage_id).to be_present
          end
        end

        it 'creates a new text message with error', perform_enqueued: true do
          Timecop.freeze(now) do
            contact = create(:contact, phone: mobile, tenant:)
            create(:message, contact:)
            # http request
            VCR.use_cassette(
              'vonage_text_message_error_interaction',
              match_requests_on: [:host]
            ) do
              post(url, params:)
            end
            # status code expectations
            expect(response).to have_http_status(:ok)
            # data expectations
            expect(Contact.count).to eq(1)
            # user message
            user_message = Message.user.last
            expect(user_message).to be_sent
            expect(user_message.vonage_id).to be_present
            # system message
            system_message = Message.system.last
            expect(system_message).to be_present
            expect(system_message).to be_sent
            expect(system_message.vonage_id).to be_present
          end
        end

        it 'create a new message with previous messages',
           perform_enqueued: true do
          Timecop.freeze(now) do
            contact = create(:contact, phone: mobile, tenant:)
            create(
              :message,
              body: 'La proxima semana tengo una presentacion de ' \
                    'la importancia de dormir',
              contact:
            )
            create(
              :message,
              sender: Message::Sender::SYSTEM,
              body: 'Mantén la respiración lenta y profunda, y ' \
                    'trata de mantenerte enfocado',
              contact:
            )
            prompt = 'Gracias. Por cierto, mencioné que tenía un proyecto ' \
                     'importante la semana pasada. ¿Recuerdas cuál era?'
            params[:text] = prompt
            params[:vonage][:text] = prompt
            # http request
            VCR.use_cassette(
              'vonage_text_messages_interaction',
              match_requests_on: [:host]
            ) do
              post(url, params:)
            end
            # status code expectations
            expect(response).to have_http_status(:ok)
            # data expectations
            expect(Contact.count).to eq(1)
            # user message
            user_message = Message.user.last
            expect(user_message).to be_sent
            expect(user_message.vonage_id).to be_present
            # system message
            system_message = Message.system.last
            expect(system_message).to be_present
            expect(system_message).to be_sent
            expect(system_message.vonage_id).to be_present
          end
        end

        it 'creates a new text message with image', perform_enqueued: true do
          Timecop.freeze(now) do
            contact = create(:contact, phone: mobile, tenant:)
            create(:message, contact:)
            # setup params
            params.deep_merge!(
              message_type: 'image',
              image: {
                url: 'https://api-eu.nexmo.com/v3/media/87226dc6-abd8-4f87-' \
                     '9d34-9fc2e53c21a3',
                caption: 'Me ayudarias a traducir lo siguiente al español ' \
                         'porfavor?'
              }
            )
            # http request
            VCR.use_cassette(
              'vonage_image_messages_interaction',
              match_requests_on: [:host]
            ) do
              post(url, params:)
            end
            # status code expectations
            expect(response).to have_http_status(:ok)
            # data expectations
            expect(Contact.count).to eq(1)
            # user message
            user_message = Message.user.last
            expect(user_message).to be_sent
            expect(user_message).to be_image
            expect(user_message.vonage_id).to be_present
            expect(user_message.media_url).to be_present
            # system message
            system_message = Message.system.last
            expect(system_message).to be_present
            expect(system_message).to be_sent
            expect(system_message.vonage_id).to be_present
          end
        end

        it 'creates a new text message with audio', perform_enqueued: true do
          Timecop.freeze(now) do
            contact = create(:contact, phone: mobile, tenant:)
            create(:message, contact:)
            # setup params
            params.deep_merge!(
              message_type: 'audio',
              audio: {
                url: 'https://api-eu.nexmo.com/v3/media/62872640-030c-4118-' \
                     'bf4e-76587b03141e',
                caption: 'Me ayudarias a traducir lo siguiente al español ' \
                         'porfavor?'
              }
            )
            # http request
            VCR.use_cassette(
              'vonage_audio_messages_interaction',
              match_requests_on: [:host]
            ) do
              post(url, params:)
            end
            # status code expectations
            expect(response).to have_http_status(:ok)
            # data expectations
            expect(Contact.count).to eq(1)
            # user message
            user_message = Message.user.last
            expect(user_message).to be_sent
            expect(user_message).to be_audio
            expect(user_message.vonage_id).to be_present
            expect(user_message.media_url).to be_present
            # system message
            system_message = Message.system.last
            expect(system_message).to be_present
            expect(system_message).to be_sent
            expect(system_message.vonage_id).to be_present
          end
        end
      end
    end
  end

  describe 'POST /vonage/status' do
    let!(:url) { status_v1_vonage_index_url }

    context 'without auth' do
      let!(:vonage_id) { 'e488f298-e002-42b6-b3c8-2654758c2255' }

      let!(:contact) { create :contact, tenant: }

      let!(:message) do
        create(:message, vonage_id:, contact:)
      end

      let!(:params) do
        {
          to: '525583728174',
          from: '14157386102',
          channel: 'whatsapp',
          message_uuid: vonage_id,
          timestamp: '2023-04-08T15:08:17Z',
          status: 'read',
          vonage: {
            to: '525583728174',
            from: '14157386102',
            channel: 'whatsapp',
            message_uuid: vonage_id,
            timestamp: '2023-04-08T15:08:17Z',
            status: 'read'
          }
        }
      end

      it 'updates a Message status' do
        # http request
        post(url, params:)
        # status code expectations
        expect(response).to have_http_status(:ok)
        # database expectations
        message.reload
        expect(message).to be_read
      end

      it 'does not update an invalid Message status' do
        # invalid HTTP params
        params[:status] = 'INVALID'
        # http request
        post(url, params:)
        # status code expectations
        expect(response).to have_http_status(:ok)
        # database expectations
        message.reload
        expect(message).not_to be_read
      end

      it 'does not update an invalid Message uuid' do
        # invalid HTTP params
        params[:message_uuid] = 'INVALID'
        # http request
        post(url, params:)
        # status code expectations
        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
