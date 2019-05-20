$(window).on("load", function () {
    $(window).scroll(function () {
        if ($("#site-nav").offset().top > 0) {
            $("#site-nav").addClass(".nav-scroll");
        } else {
            $("#site-nav").removeClass(".nav-scroll");
        }
    });
});