class CelebritySpotting < Sinatra::Base
  # Create a path to an endpoint that we can provide as our webhook URL.
  post '/messages' do

    # We're going to be returning TwiML, so we'll create a new
    # Twilio::TwiML::MessagingResponse and set the content type header to
    # text/xml
    content_type = "text/xml"
    twiml = Twilio::TwiML::MessagingResponse.new

    # Look for the NumMedia parameter sent by Twilio to tell whether there is
    # any media. If there is, the image URL will be in the MediaUrl0 parameter.
    #With that MediaUrl0 parameter we can use Down to download the image. When you
    # download an image with the Down gem it gives you a Tempfile
    if params["NumMedia"].to_i > 0
      tempfile = Down.download(params["MediaUrl0"])
      begin
        # To spot celebrities in our pictures we need to create a client to use
        # the AWS API and send the image to the recognizing celebrities endpoint.
        client = Aws::Rekognition::Client.new
        response = client.recognize_celebrities image: { bytes: tempfile.read }
        if response.celebrity_faces.any?
          if response.celebrity_faces.count == 1
            celebrity = response.celebrity_faces.first
            twiml.message body: "Ooh, I am #{celebrity.match_confidence}% confident this looks like #{celebrity.name}."
          else
            twiml.message body: "I found #{response.celebrity_faces.count} celebrities in this picture. Looks like #{to_sentence(response.celebrity_faces.map { |face| face.name }) } are in the picture."
          end
        else
          case response.unrecognized_faces.count
          when 0
            twiml.message body: "I couldn't find any faces in that picture. Maybe try another pic?"
          when 1
            twiml.message body: "I found 1 face in that picture, but it didn't look like any celebrity I'm afraid."
          else
            twiml.message body: "I found #{response.unrecognized_faces.count} faces in that picture, but none of them look like celebrities."
          end
        end
        # twiml.message body: "Thanks for the image! It's #{tempfile.size} bytes large."
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

  # helper function to turn a list of names into a readable sentence
  def to_sentence(array)
    return array.to_s if array.length <= 1
    "#{array[0..-2].join(", ")} and #{array[-1]}"
  end

end
