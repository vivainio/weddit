root = window

_.templateSettings = {
  interpolate : /\{\{(.+?)\}\}/g
};



class RedditEngine
    initialize: ->
        pat = $("#linktemplate").html()
        console.log pat
        
        @linktmpl = _.template pat
        console.log "template", @linktmpl

    fetchLinks: (cat, qargs) ->
        cat = "pics"
        selector = ""
        qargs = qargs = "jsonp=?&"
        url = "http://www.reddit.com/r/#{cat}/#{selector}.json?#{qargs} "

        console.log "going ajax"
        $.ajax
            url: url
            jsonp: "jsonp"
            dataType: "jsonp"
            success: (resp) =>
                items = resp.data.children
                all = $("<div>")
                root = $("div[data-catname='pics']")
                for it in items
                    d = it.data
                    expanded = @linktmpl
                    
                        linkdesc: d.title
                        linkscore: d.score
                        linkimg: d.thumbnail
                        
                    console.log expanded
                    all.append(expanded)
                    
                root.empty()
                root.append(all)
                console.log items
                
        """        
        $.getJSON url, (resp) =>
            items = resp.data.children
            for it in items
                console.log it
        """       

root.RedditEngine = RedditEngine    
    
reng = null
    
$ ->
    console.log "starting up"
    root.redditengine = reng = new RedditEngine()
    reng.initialize()
    reng.fetchLinks "", ""
