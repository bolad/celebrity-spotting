# celebrity-spotting
When Twilio receives a WhatsApp message it will send an HTTP request, a webhook, to a URL we provide. 
This application can receive those webhooks, process the image using the AWS Rekognition service and then send a message back in 
the response to Twilio.
