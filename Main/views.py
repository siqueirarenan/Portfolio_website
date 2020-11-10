from django.shortcuts import render
from django.http import HttpResponseRedirect
from string import Template
import requests
from django.conf import settings


def index(request,msg_sent_bool=0):
    projects = ProjectsList()
    projects += [ProjectItem("Finite Element Analysis Web App",
                          "Web application with 3D configuration on the client-side and numeric calculations on the serve-side",
                          ["python-logo.png","coffeescript.png","javascript.png","django.png",
                           "ajax.png","seen.png"],
                          "FEproject.png",
                          "FE_project", True)]
    projects += [ProjectItem("Sight Reading Trainner Web App",
                             "Java web application running with no need for support on the browser.",
                             ["java.png","maven.png","jpro.png","jfugue.png",
                              "docker.png"],
                             "sightreading.PNG",
                             "https://sight-reading-trainer-webapp.herokuapp.com/", True)]
    projects += [ProjectItem("Duolingo Chrome Extension",
                             "Chrome extension for adding sentence related pictures to the Duolingo app.",
                             ["javascript.png","react.jpg","html.png","chrome.png"],
                             "Duolingo.png",
                             "https://github.com/siqueirarenan/Duolingo_Pic")]
    projects += [ProjectItem("Topology Optimization Plug-in",
                             "Plug-in to run a self-developed topology optimization method in Abaqus CAE.",
                             ["python-logo.png","abaqus.png"],
                             "IZEOabaqus2.png",
                             "https://github.com/siqueirarenan/IZEO_Topology_optimization_Abaqus_script")]
    projects += [ProjectItem("COVID-19 Data Analysis",
                             "In-development database and UI for analysis of COVID-19 statistics.",
                             ["python-logo.png","django.png","react.jpg","mysql.jpg","restapi.png"],
                             None,
                             "https://github.com/siqueirarenan/Coronavirus-data-analysis")]

    context = {'msg_sent_bool': str(msg_sent_bool),
               'projects' : projects}
    return render(request,'Main/index.html',context)


def contact_submit(request):

    v_name = request.GET['Name']
    v_email = request.GET['Email']
    v_subject = request.GET['Subject']
    v_comment = request.GET['Comment']

    message_template = Template("PORTFOLIO CONTACT FORM\n\nName: ${NAME}\nEmail: ${EMAIL}\nSubject: ${SUBJECT}\n\nMessage:\n\n${MESSAGE}\n--")

    message = message_template.substitute(NAME=v_name,EMAIL=v_email,SUBJECT=v_subject,MESSAGE=v_comment)

    f = open(settings.BASE_DIR / "Main/credentials.txt",'rt')
    mailgun = f.readlines()
    f.close()

    resp = requests.post(mailgun[0][0:-1],auth=("api", mailgun[1][0:-1]),data={"from": mailgun[2],"to": ["renansiqueira@gmail.com"],"subject": "Portfolio Contact Form - " + v_subject,"text": message})

    if resp.status_code == 200:
        return HttpResponseRedirect("/1#contact")
    else:
        return HttpResponseRedirect("/2#contact")


class ProjectItem:
    def __init__(self, name, text, tools, main_pic, href, tryYourself=False):
        self.name = name
        self.text = text
        self.tools = tools
        self.mainPic = main_pic
        self.href = href
        self.tryYourself = tryYourself

class ProjectsList:
    def __init__(self):
        self.elements = []

    def __getitem__(self, item):
        return self.elements[item]

    def __add__(self, other):
        assert (isinstance(other[0], ProjectItem))
        self.elements += other

        return self

    def __len__(self):
        return len(self.elements)
