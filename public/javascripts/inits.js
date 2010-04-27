                    tinyMCE.init({
                            mode:"textareas",
                            editor_selector : "tiny_mce"
                    });
                    function setAuction(frm) /* wyłącz pola kup-teraz */
                    {
						 frm.ch_buyNow.checked=false;  /* wyłącz checkbox*/
                         frm.minimal_price.disabled=false;
                         frm.minimal_bidding_difference.disabled=false;
                         frm.buy_now_price.disabled=true;
                    }

                    function setBuyNow(frm)  /*wyłącz pola licytacji*/
                    {
                          frm.ch_auction.checked=false; /* wyłącz checkbox*/
						  frm.site_link_auction_attributes_buy_now_price.disabled=false;
                          frm.minimal_price.disabled=true;
                          frm.minimal_price.value=0.0;
                          frm.minimal_bidding_difference.disabled=true;
                    }

                    $(function() {
                        $("#datepicker_from").datepicker({
                              showOn: 'button',
                              buttonImage: '/images/calendar.gif',
                              buttonImageOnly: true
                        });
                        $("#datepicker_to").datepicker({
                              showOn: 'button',
                              buttonImage: '/images/calendar.gif',
                              buttonImageOnly: true
                        });
                    });

        $(document).ready(function()
        {
          $("#search_categories").fcbkcomplete({
            firstselected: true,
            cache: true,
            filter_case: true,
            filter_hide: true});
          
        });