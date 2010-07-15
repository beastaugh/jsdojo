NewsService = new JS.Class('NewsService', {
    include: Ojay.Observable,
    
    initialize: function() {
        var service = this;
        
        setInterval(function() {
            Ojay.HTTP.GET('http://beastaugh.othermedia.com:4567/news.json', {jsonp: 'callback'}, {
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

makeNewsItemHTML = function(newsItem, klass) {
    var className = ['news-item'];
    
    if (klass) className.push(klass);
    if (newsItem.update) className.push('update');
    
    return Ojay.HTML.div({className: className.join(' ')}, function(H) {
        H.p(newsItem.text);
        H.p({className: 'timestamp'}, newsItem.timestamp.toString());
    });
};

insertNewsItem = function(newsItemHTML, element) {
    if (element) {
        Ojay(element).insert(newsItemHTML, 'after');
    } else {
        Ojay.byId('news-items').insert(newsItemHTML, 'top');
    }
};
