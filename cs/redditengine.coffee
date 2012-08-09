root = window

class App
    start: ->
        @topicGroups = new RTopicGroupList
        
        @topicGroups.fetch()
        
        @shownCategories = new RCatList
        
        root.redditengine = reng = new RedditEngine()

        @tgview = tg = new RTopicGroupView
        #tg.addTg "Funny stuff", ["pics", "fffffffuuuuuuuuuuuu"]
        #tg.addTg "Programming", ["javascript", "html5", "coffeescript"]
        
        #@topicGroups.sync()
        @tgview.render()

        @mainview = mv = new RCatListView

        @vManageGroups = mg = new VManageGroups
        mg.render()

        @vGroupEditor = ge = new VGroupEditor
        
        EventDispatcher.bind "selectCategories", (ev, cats) =>
            console.log cats
            mv.setCategories (cats)
            mv.render()
            reng.fetchAll()

        reng.initialize()
        reng.fetchAll()        


EventDispatcher = $({})

app = new App()


logg = ->
    1

collectionToJson = (coll)->    
    coll.map (m) ->
        o = m.toJSON()
        o.cid = m.cid
        o
    
    
class RLink extends Backbone.Model
    defaults:
        linkdesc: "no description"

class RCat extends Backbone.Model
    defaults:
        name: "funny"


class RTopicGroup extends Backbone.Model
    defaults:
        groupName: "mygroup"
        topics: ["pics", "funny"]

class RTopicGroupList extends Backbone.Collection
    localStorage: new Store("topicgroups")
    model: RTopicGroup
    
class RTopicGroupView extends Backbone.View
    el: "#topic-group-area"
    
    initialize: ->
        pat = $("#topic-group-template").html()
        @template = Handlebars.compile pat        
        @tglist = app.topicGroups
        @tglist.bind "change", (args...) =>
            console.log "Changed!",args
            @render()
        
    render: ->
        @$el.empty()
        #console.log JSON.stringify @tglist.toJSON()
        @tglist.each (m) =>
            rend = @template
                tgname: m.get "groupName"
                topics: m.get "topics"
                tgid: m.cid
                
            logg "Rendered",rend
            @$el.append rend
            
    addTg: (name, topics) ->
        
        @tglist.create groupName: name, topics: topics
        #m = new Backbone.Model 
        #@tglist.add m

    makeCurrent: (elem) ->
        $(".tg-current-choice").removeClass "tg-current-choice"
        elem.addClass "tg-current-choice"
        
    doSelectGroup: (ev) ->        
        trg = $(ev.target)
        cid = trg.data("cid")
        @makeCurrent trg
        m = @tglist.getByCid cid
        
        
        EventDispatcher.trigger "selectCategories", [m.get "topics"]
        
    
    doSelectTopic: (ev) ->
        trg = $(ev.target)
        @makeCurrent trg
        topic = trg.text()
        console.log "topic", topic
        EventDispatcher.trigger "selectCategories", [[topic]]
        

    events: 
        "click .tg-name" : "doSelectGroup"
        "click .tg-topic" : "doSelectTopic"
    

class RLinkList extends Backbone.Collection
    model: RLink
    
class RCatList extends Backbone.Collection
    model: RCat
    
class RCatListView extends Backbone.View

    el: "#catlist-container"
    
    initialize:  ->                
        _.bindAll @        
        @categories_coll = new RCatList
        pat = $("#catlist-template").html()
        @catlisttmpl = Handlebars.compile pat
        @singlecatviews = {}
            
        
    render: ->
        @$el.empty()
        
        all = $('<div class="gen-cat-list-container">')
        app.shownCategories.each (m) =>
            name = m.get "name"
            rendered = @catlisttmpl
                catname: name
             
            appended = $(rendered).appendTo(all)
            
            r = appended.find(".catlist-links")
            
            #if name in @singlecatviews
            #    @singlecatviews[name].el = r
            #else
            nv = new RCatView el: r
            @singlecatviews[name] = nv
            
    
        #console.log ["catlistview render", all]
        
        @$el.append(all)
        
    
    setCategories: (cats)->
        app.shownCategories.reset ({name} for name in cats)
    
    addCategory: (name) ->
        m = new RCat
        m.set "name": name
        app.shownCategories.add m
    
    getView: (name) -> @singlecatviews[name]
        
    categories: -> @categories_coll
        
    
    
class RCatView extends Backbone.View
    
    events:
        "click .linkcontainer"  : "doSelect"
        "click .rightedge" : "doSelectComments"
        #"click .linkcomments" : "doSelectComments"
        
    modelByCid: (cid) -> @coll.getByCid cid
        
        
    openWindow: (url) ->
        window.open url
        
    doSelect: (ev) ->
        
        cid = $(ev.currentTarget).data("cid")
        #console.log ev, cid
        m = @modelByCid cid
        #console.log m
        url = m.get "url"
        @openWindow url
        
    
    doSelectComments: (ev) ->
        cid = $(ev.currentTarget).parent().data("cid")
        
        m = @modelByCid cid
        plink = m.get "permalink"
        console.log ["comments!", m, m.get "permalink" ]
        
        fullurl = "http://reddit.com" + plink+".compact"
        @openWindow fullurl
        
        
        ev.stopPropagation()
        
    initialize: ->
        @coll = new RLinkList
        _.bindAll @
        pat = $("#link-template").html()
        @linktmpl = Handlebars.compile pat
        
        
    renderOne: (m) ->    
        expanded = @linktmpl
        
            linkdesc: m.get "title"
            linkscore: m.get "score"
            linkimg: m.get "thumbnail"
            linkcomments: m.get "num_comments"
            cid: m.cid
            
        expanded
    
    render: ->
        all = $('<ul data-role="listview" data-theme="g">')
        @coll.each (m) =>
            all.append $(@renderOne(m))
                
        
        @$el.empty()
        @$el.append all
        all.listview()
        all.listview("refresh")

    mkModel: (d) ->
        m = new RLink
        m.set d
        #console.log m
        m
        
    addLink: (d) ->
        m = @mkModel d
        @coll.add m

class VManageGroups extends Backbone.View
    el: "#manage-groups-area"
    
    events:
        "click .topic-group-item" : "doSelectGroup"
        "click #btnNewGroup" : "doNewGroup"
        
    initialize: ->
        _.bindAll @
        pat = $("#manage-groups-template").text()
        @tmplManageGroups = Handlebars.compile pat
        app.topicGroups.bind "change remove", =>
            @render()
            
    
        
        #console.log "init!",pat
        

    render: ->        
        context = { groups: collectionToJson app.topicGroups }
        console.log context
        h = @tmplManageGroups context
        @$el.html h
        @.$(".rootlist").listview("refresh")
        
    modelByCid: (cid) -> app.topicGroups.getByCid cid
        
    doSelectGroup: (ev) ->        
        m = @modelByCid $(ev.currentTarget).data("cid")

        @switchToGroupEditor m         
    
    switchToGroupEditor: (m) ->
        app.vGroupEditor.model = m
        app.vGroupEditor.render()

        $("#pagegroupeditor").page()
        _.defer =>        
            $.mobile.changePage "#pagegroupeditor"
            app.vGroupEditor.updateList()
        
        
    doNewGroup: (ev) ->
        console.log "Add new group"
        m = app.topicGroups.create groupName: "<untitled>", topics: []
        #app.tgview.render()
        #app.vManageGroups.render()
        @switchToGroupEditor m
        app.vGroupEditor.model = m
        
        
class VGroupEditor extends Backbone.View
    el: "#group-editor-area"
    
    events:
        "click #btnAdd": "doAddCat"
        "click .aRemoveCat": "doRemoveCat"
        "click #btnApplyChangeGroupName" : "doChangeGroupName"
        
    initialize: ->
        _.bindAll @
        pat = $("#group-editor-template").text()
        @tmpl = Handlebars.compile pat
    
        $("#btnDeleteGroup").on "click", =>
            console.log "Delete group!"
            #app.topicGroups.remove @model
            @model.destroy()
            history.back()
            
    
        
        #$("#pagegroupeditor").on "pagebeforecreate", =>
        #    @render()
        
    updateList: ->
        ul = @.$(".rootlist")        
        ul.listview()
        
    render: ->
        console.log "render"
        if not @model
            return
            
        context = @model.toJSON()
        h = @tmpl context
        @$el.html h
        
    doAddCat: (ev) ->
        
        t = $("#inpNewCategory").val()
        console.log "add cat",t
        if t.length < 1
            return
        m = @model
        topics = m.get "topics"        
        console.log "add to",topics
        topics.push t
        m.set "topics", topics
        m.save()
        @render()
        @updateList()
        
    doRemoveCat: (ev) ->
        elem =  $(ev.currentTarget)
        toRemove = elem.text()
        console.log "Remove cat", toRemove
        ul = @.$(".rootlist")
        m = @model
        topics = _.without m.get("topics"), toRemove
        m.set "topics", topics
        m.save()
        @render()
        @updateList()
        
    doChangeGroupName: (ev) ->
        t = $("#inpGroupName").val()
        console.log "Change to",t
        @model.set "groupName", t
        @model.save()
        
        
        
class RedditEngine    
    initialize: ->        
        #@linktmpl = _.template pat
        #console.log "template", @linktmpl
        @cats = []
        @linkviews = {}
        #@mkView "pics"
        #@mkView "funny"
        
        
        
        
        #mv.setCategories ["pics", "javascript"]
        #@mainview.addCategory("pics")
        #@mainview.addCategory("funny")
        #@mainview.render()

        
        
    fetchAll: ->
        
        app.shownCategories.each (m) => @fetchLinks m.get "name",""
            
    fetchLinks: (cat, qargs) ->        
        selector = ""
        qargs = qargs = "jsonp=?&"
        url = "http://www.reddit.com/r/#{cat}/#{selector}.json?#{qargs} "

        
        lv = app.mainview.getView(cat)
        $.ajax
            url: url
            jsonp: "jsonp"
            dataType: "jsonp"
            success: (resp) =>
                items = resp.data.children
                #all = $("<div>")
                for it in items
                    d = it.data
                    #console.log d
                    
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
    logg "starting up"
    app.start()
    
