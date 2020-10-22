from django.shortcuts import render
#from django.template import loader
#from django.http import HttpResponse, HttpResponseRedirect
#from django.core.mail import send_mail
#from django.core import mail
#from django.db import models
#import smtplib
from string import Template
import requests
#from email.mime.multipart import MIMEMultipart
#from email.mime.text import MIMEText

def index(request,msg_sent_bool=0):
    context = {'msg_sent_bool': str(msg_sent_bool)}
    return render(request,'Main/index.html',context)

def contact_submit(request):

    v_name = request.GET['Name']
    v_email = request.GET['Email']
    v_subject = request.GET['Subject']
    v_comment = request.GET['Comment']

    message_template = Template("PORTFOLIO CONTACT FORM\n\nName: ${NAME}\nEmail: ${EMAIL}\nSubject: ${SUBJECT}\n\nMessage:\n\n${MESSAGE}\n--")

    message = message_template.substitute(NAME=v_name,EMAIL=v_email,SUBJECT=v_subject,MESSAGE=v_comment)

    #send_mail("Portfolio Contact Form - " + v_subject, message,maitsuada@outlook.de", ['renansiqueira@gmail.com'],fail_silently=False,)

    f = open("/home/renansiqueira/RenanPortfolio/Main/credentials.txt",'r')
    url_adress = f.readline()
    api_key = f.readline()
    contact_details = f.readline()
    f.close()

    requests.post(url_adress,
    	auth=("api", api_key),
    	data={"from": contact_details,
    		"to": ["renansiqueira@gmail.com"],
    		"subject": "Portfolio Contact Form - " + v_subject,
    		"text": message})

    return HttpResponseRedirect("/1#contact")



    # set up the SMTP server
    #s = smtplib.SMTP(host='smtp-mail.outlook.com', port=587)
    #s.ehlo()
    #s.starttls()
    #s.login("maitsuada@outlook.de", "Raquoasi7&HM")

    #msg = MIMEMultipart()       # create a message

    # add in the actual person name to the message template

    # setup the parameters of the message
    #msg['From']="maitsuada@outlook.de"
    #msg['To']="renansiqueira@gmail.com"
    #msg['Subject']="Portfolio Contact Form - " + v_subject

    # add in the message body
    #msg.attach(MIMEText(message, 'plain'))

    # send the message via the server set up earlier.
    #s.send_message(msg)

    #del msg
    #s.quit()





