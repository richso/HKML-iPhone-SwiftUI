$j(document).ready(function() {
    var $ = $j;
    
    var userAgent = window.navigator.userAgent;
    
    var appHead = $('html').attr('hkmlApp_head');
    
    if (! appHead) {
        $('html').attr('hkmlApp_head', 1);
        
        try {
            var d = $('<div style="position: fixed; bottom:0; width: calc(100% - 40px); height: 40px; background-color: #eeeeee; padding: 0 20px;"></div>')
                .append('<a href="javascript:void(0);" onclick="window.history.back()" style="float: left; padding: 5px; font-size: 24px;">&#9664;</a>')
                .append('<a href="javascript:void(0);" onclick="window.history.forward()" style="float: left; padding: 5px; font-size: 24px;">&#9654;</a>')
                .append('<a href="javascript:void(0);" onclick="location=\'https://m.facebook.com/groups/86899893467/\';" style="float: right; padding: 5px; font-size: 24px;">&#127968;</a>')
                .append('<a href="facebookshare:'+location.href+'" style="float: right; padding: 5px; font-size: 24px;">&#9734;</a>');
            
            d.append('<div style="clear: both;"></div>');

            $('<div style="height: 60px;"></div>').appendTo('body');
            d.appendTo('body');
        } catch (e) {}
        
    }
    
})

