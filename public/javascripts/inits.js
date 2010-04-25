                    tinyMCE.init({
                            mode:"textareas",
                            editor_selector : "tiny_mce"
                    });
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
            cache: true});

          setWizardCheckboxes();

        });