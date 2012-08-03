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
        @coll = new RLinkList
        _.bindAll @
        pat = $("#linktemplate").html()
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
            all.append $(@renderOne(m))
        
        console.log(all)
        
        @el.empty()
        @el.append all

    mkModel: (d) ->
        m = new RLink
        m.set d
        #console.log m
        m
        
    addLink: (d) ->
        m = @mkModel d
        @coll.add m


class RedditEngine    
    initialize: ->
        pat = $("#linktemplate").html()
        console.log pat
        
        @linktmpl = _.template pat
        console.log "template", @linktmpl
        @cats = []
        @linkviews = {}
        @mkView "pics"
        @mkView "funny"

    mkView: (name) ->
        sel = "div[data-catname='#{name}']"
        root = $(sel)
        lv = new RCatView root
        
        @cats.push name
        @linkviews[name]= lv        
        
        
        
    fetchAll: ->
        for cat in @cats
            @fetchLinks cat, ""
            
    fetchLinks: (cat, qargs) ->
        cat = "pics"
        selector = ""
        qargs = qargs = "jsonp=?&"
        url = "http://www.reddit.com/r/#{cat}/#{selector}.json?#{qargs} "

        console.log "going ajax"
        lv = @linkviews[cat]
        $.ajax
            url: url
            jsonp: "jsonp"
            dataType: "jsonp"
            success: (resp) =>
                items = resp.data.children
                #all = $("<div>")
                for it in items
                    d = it.data
                    
                    lv.addLink d
                    #all.append(expanded)
                    
                #console.log items
                lv.render()
                
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
    reng.fetchAll()        
