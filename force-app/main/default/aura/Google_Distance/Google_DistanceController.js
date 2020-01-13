({invoke: function(component,event,helper)
  { 
      var args = event.getParam("arguments");
      var callback = args.callback;
      var xhttp = new XMLHttpRequest();
      xhttp.onreadystatechange = $A.getCallback(function()
                                                {
                                                    if (this.readyState == 4)
                                                    {
                                                        alert(this.status);
                                                        alert(xhttp.responseText);
                                                        var response = JSON.parse(xhttp.responseText);
                                                        component.set("v.distance",response.distance);
                                                        callback("SUCCESS");
                                                    }
                                                })
      var origin = component.get("v.origin");
      var destination = component.get("v.destination");
      var url = "http://www.distance24.org/route.json?stops=" + origin + "|" + destination;
      xhttp.open("GET",url);
      xhttp.setRequestHeader("Referer","");
      xhttp.send(null);
  }
 })