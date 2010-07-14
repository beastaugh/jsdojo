NewsService = new JS.Class('NewsService', {
    include: Ojay.Observable,
    
    initialize: function() {
        var service = this;
        
        setInterval(function() {
            Ojay.HTTP.GET('http://wp.dev:4567/news.json', {jsonp: 'callback'}, {
                onSuccess: function(data) {
                    service.notifyObservers('data', data);
                }
            });
        }, service.klass.INTERVAL);
    },
    
    extend: {
        INTERVAL: 5000
    }
});

insertNewsItem = function(newsItem, element) {
    var newsItemHTML = Ojay.HTML.div({
        className: 'news-item' + (newsItem.update ? ' update' : '')
    }, function(H) {
        H.p(newsItem.text);
        H.p({className: 'timestamp'}, newsItem.timestamp.toString());
    });
    
    if (element) {
        Ojay(element).insert(newsItemHTML, 'after');
    } else {
        Ojay.byId('news-items').insert(newsItemHTML, 'top');
    }
};
