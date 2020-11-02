function setSteel(){
    document.getElementById("material").innerHTML = "Steel"
    document.getElementById("Emodul").value = "210"
    document.getElementById("Poisson").value = "0.3"
}
function setAluminum(){
    document.getElementById("material").innerHTML = "Aluminum"
    document.getElementById("Emodul").value = "70"
    document.getElementById("Poisson").value = "0.33"
}
function setSilver(){
    document.getElementById("material").innerHTML = "Silver"
    document.getElementById("Emodul").value = "210"
    document.getElementById("Poisson").value = "0.3"
}
function setUserMat(){
    document.getElementById("material").innerHTML = "User-defined"
    document.getElementById("Emodul").value = ""
    document.getElementById("Poisson").value = ""
}
function setUserMat2(){
    document.getElementById("material").innerHTML = "User-defined"
}
function add_condition(){
    var node = document.body.children[2]
    var cln = node.cloneNode(true);
    cln.id = String(cln.id).substr(0,cln.id.length-1) + (document.body.children.length - 1)
    for (ipt of cln.children){
        ipt.value = ""
        ipt.style = ""
        ipt.id = String(ipt.id).substr(0,ipt.id.length-1) + (document.body.children.length - 1)
    }
    document.body.appendChild(cln)
}
function remove_condition(){
    if (document.body.children.length > 3){
        document.body.lastChild.remove();
    }
}
function buttonBC(id){
    if (document.getElementById(id).value == ""){
        document.getElementById(id).value = "1"
        document.getElementById(id).style = "color:white;background-color:#a1a1a1;"
    }else{
        document.getElementById(id).value = ""
        document.getElementById(id).style = ""
    }
}
function onload(){
    document.getElementById('load_frame').contentWindow.updateLoads = updateLoads;
    document.getElementById('load_frame').contentWindow.removeLoads = removeLoads;
    }




