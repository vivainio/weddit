root = window

_.templateSettings = {
  interpolate : /\{\{(.+?)\}\}/g
};

class RLink extends Backbone.Model
    defaults:
        linkdesc: "no description"

class RCat extends Backbone.Model
    defaults:
        name: "funny"

class RTopicGroup extends Backbone.Collection
    model: RCat


class RLinkList extends Backbone.Collection
    model: RLink
    
class RCatList extends Backbone.Collection
    model: RCat
    
class RCatListView extends Backbone.View    
    constructor:  ->
        
        @el = $("#catlist-container")
        _.bindAll @        
        @categories_coll = new RCatList
        pat = $("#catlist-template").html()
        @catlisttmpl = Handlebars.compile pat
        @singlecatviews = {}
        
            
        
    render: ->
        @el.empty()
        
        all = $('<div class="gen-cat-list-container">')
        @categories_coll.each (m) =>            
            
            name = m.get "name"
            rendered = @catlisttmpl
                catname: name
             
            appended = $(rendered).appendTo(all)
            
            r = appended.find(".catlist-links")
            
            if name in @singlecatviews
                @singlecatviews[name].el = r
            else
                nv = new RCatView(r)
                @singlecatviews[name] = nv
                
        
        #console.log ["catlistview render", all]
        
        @el.append(all)
        
    
    addCategory: (name) ->
        m = new RCat
        m.set "name": name
        @categories_coll.add m
    
    getView: (name) -> @singlecatviews[name]
        
    categories: -> @categories_coll
        
    
    
class RCatView extends Backbone.View

    constructor: (el) ->
        @el = el
        @coll = new RLinkList
        _.bindAll @
        pat = $("#link-template").html()
        @linktmpl = Handlebars.compile pat
                
        
        
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
        #@linktmpl = _.template pat
        #console.log "template", @linktmpl
        @cats = []
        @linkviews = {}
        #@mkView "pics"
        #@mkView "funny"        
        @mainview = new RCatListView 
        @mainview.addCategory("pics")
        @mainview.addCategory("funny")
        @mainview.render()
        

    mkView: (name) ->
        sel = "div[data-catname='#{name}']"
        root = $(sel)
        lv = new RCatView root
        
        @cats.push name
        @linkviews[name]= lv        
        
        
        
    fetchAll: ->
        
        @mainview.categories().each (m) => @fetchLinks m.get "name",""
            
    fetchLinks: (cat, qargs) ->        
        selector = ""
        qargs = qargs = "jsonp=?&"
        url = "http://www.reddit.com/r/#{cat}/#{selector}.json?#{qargs} "

        console.log "going ajax"
        lv = @mainview.getView(cat)
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
