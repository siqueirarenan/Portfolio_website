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
    if (document.body.children.length > 4){
        document.body.lastChild.remove();
    }
}
function buttonBC(id){
    if (document.getElementById(id).value == "0"){
        document.getElementById(id).value = "1"
        document.getElementById(id).style = "color:white;background-color:#a1a1a1;"
    }else{
        document.getElementById(id).value = "0"
        document.getElementById(id).style = ""
    }
}
function onload(){
    document.getElementById('load_frame').contentWindow.updateLoads = updateLoads;
    document.getElementById('load_frame').contentWindow.removeLoads = removeLoads;
    document.getElementById('boundary_frame').contentWindow.updateBoundaries = updateBoundaries;
    document.getElementById('boundary_frame').contentWindow.removeBoundaries = removeBoundaries;
    }

function update_load_table(){
    cond = false
    count = 0
    for (input of document.body.children[document.body.children.length - 2].children){
        if (input.value == "" && count < 3){
            cond = true
        }
        count++
    }
    if (cond){
        remove_condition()
        removeLoads() //!
    }
    cond2 = true
    count2 = 0
    for (input of document.body.children[document.body.children.length - 1].children){
        if (input.value == "" && count2 < 3){
            cond2 = false
        }
        count2++
    }
    if (cond2){
        add_condition()
    }
}

function update_boundary_table(){
    cond = false
    count = 0
    for (input of document.body.children[document.body.children.length - 2].children){
        if (input.value == "" && count < 3){
            cond = true
        }
        count++
    }
    if (cond){
        remove_condition()
        removeBoundaries() //!
    }
    cond2 = true
    count2 = 0
    for (input of document.body.children[document.body.children.length - 1].children){
        if (input.value == "" && count2 < 3){
            cond2 = false
        }
        count2++
    }
    if (cond2){
        add_condition()
    }
}





