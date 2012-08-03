root = window

_.templateSettings = {
  interpolate : /\{\{(.+?)\}\}/g
};

class RLink extends Backbone.Model
    defaults:
        linkdesc: "no description"

class RLinkList extends Backbone.Collection
    model: RLink
    
class RCatView extends Backbone.View

    constructor: (el) ->
        @el = el
        
    initialize: ->
        _.bindAll @
        @coll = new RLinkList
        
        pat = $("#linktemplate").html()
        console.log pat
        
        @linktmpl = _.template pat
        
        
    renderOne: (m) ->    
        expanded = @linktmpl
        
            linkdesc: m.get "title"
            linkscore: m.get "score"
            linkimg: m.get "thumbnail"
            
        expanded
    
    render: ->
        all = $("<div>")
        @coll.each (m) =>
            all.append renderOne m
        
        @el.empty()
        @el.append all
                  
        
            
        
        
    
    
    


        



class RedditEngine
    initialize: ->
        pat = $("#linktemplate").html()
        console.log pat
        
        @linktmpl = _.template pat
        console.log "template", @linktmpl
        
        root = $("div[data-catname='pics']")
        @linkview = new RCatView(root)
        
        

    mkModel: (d) ->
        m = new RLink
        m.set d
        console.log m
        m
        
        
    fetchLinks: (cat, qargs) ->
        cat = "funny"
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
                #all = $("<div>")
                root = $("div[data-catname='pics']")
                for it in items
                    d = it.data
                    m = @mkModel d
                    @linkview.coll.add m
                    expanded = @linktmpl
                    
                        linkdesc: d.title
                        linkscore: d.score
                        linkimg: d.thumbnail
                        
                    console.log expanded
                    #all.append(expanded)
                    
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
