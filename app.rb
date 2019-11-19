class CelebritySpotting < Sinatra::Base
  # Create a path to an endpoint that we can provide as our webhook URL.
  post '/messages' do

    # We're going to be returning TwiML, so we'll create a new
    # Twilio::TwiML::MessagingResponse and set the content type header to
    # application/xml
    content_type "application/xml"
    twiml = Twilio::TwiML::MessagingResponse.new
    twiml.message body: "Hey Stan"
    twiml.to_xml
  end
end
