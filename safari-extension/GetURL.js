var GetURL = function() {};

GetURL.prototype = {
    run: function(arguments) {
        arguments.completionFunction({"title": document.title, "url": document.URL});
    }
};

var ExtensionPreprocessingJS = new GetURL;
