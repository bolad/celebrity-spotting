class CelebritySpotting < Sinatra::Base
  # Create a path to an endpoint that we can provide as our webhook URL.
  post '/messages' do

    # We're going to be returning TwiML, so we'll create a new
    # Twilio::TwiML::MessagingResponse and set the content type header to
    # text/xml
    content_type "text/xml"
    twiml = Twilio::TwiML::MessagingResponse.new

    # Look for the NumMedia parameter sent by Twilio to tell whether there is
    # any media. If there is, the image URL will be in the MediaUrl0 parameter.
    #With that MediaUrl0 parameter we can use Down to download the image. When you
    # download an image with the Down gem it gives you a Tempfile
    if params["NumMedia"].to_i > 0
      tempfile = Down.download(params["MediaUrl0"])
      begin
        twiml.message body: "Thanks for the image! It's #{tempfile.size} bytes large."
      ensure
        # Once we are done with the tempfile we should close and unlink it
        tempfile.close!
      end
    else
      # When no image is sent via the MediaUrl0 param
      twiml.message body: "I can't look for celebrities if you don't send me a picture!"
    end
    twiml.to_xml
  end
end
