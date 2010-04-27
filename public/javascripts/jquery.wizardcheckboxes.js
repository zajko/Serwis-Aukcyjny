
function setWizardCheckboxes(){
  if((!$("#ch_buyNow").attr("checked","checked") && !$("#ch_auction").attr("checked","checked")) ||
    ($("#ch_buyNow").attr("checked","checked") && $("#ch_auction").attr("checked","checked"))){
          setBuyNowAuction();
      }
  $("#ch_buyNow").click(function() {
      if($("#ch_buyNow").attr("checked")){ setBuyNowAuction();}
      else{ setSimpleAuction();}
      });
  $("#ch_auction").click(function() {
      if($("#ch_auction").attr("checked")){setSimpleAuction();}
      else{setBuyNowAuction();}
      });
}

function setBuyNowAuction(){
     $("#ch_auction").removeAttr("checked");
     $("#ch_buyNow").attr("checked","checked");
     cssSelectBox($("#div_buyNow"));
     cssDisableBox($("#div_auction"));
     disableSimpleAuctionAttr();
     setBuyNowAuctionAttr();
}

function setSimpleAuction(){
    $("#ch_auction").attr("checked","checked");
    $("#ch_buyNow").removeAttr("checked");
    cssSelectBox($("#div_auction"));
    cssDisableBox($("#div_buyNow"));
    setSimpleAuctionAttr();
    disabledBuyNowAuctionAttr();
}


function disableSimpleAuctionAttr(){
      $("#minimal_price").attr("disabled","disabled");
      $("#minimal_bidding_difference").attr("disabled","disabled");
}
function setSimpleAuctionAttr(){
       $("#minimal_price").removeAttr("disabled");
       $("#minimal_bidding_difference").removeAttr("disabled");
}
function disabledBuyNowAuctionAttr(){
    $("#buy_now_price").attr("disabled","disabled");
}
function setBuyNowAuctionAttr(){
    $("#buy_now_price").removeAttr("disabled")
}

function cssSelectBox(item){
    $(item).css("background","#d5f39b");
    $(item).css("border","1px solid #000000");
    $(item).css("color","#000000");

}
function cssDisableBox(item){
    $(item).css("background","#ffffff");
    $(item).css("border","1px solid #cccccc");
    $(item).css("color","#cccccc");
}