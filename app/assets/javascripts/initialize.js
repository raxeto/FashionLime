window.FashionLime = {};
window.FashionLime.Common = {};
window.FashionLime.Product = {};
window.FashionLime.Profile = {};
window.FashionLime.Cart = {};
window.FashionLime.Order = {};
window.FashionLime.Outfit = {};
window.FashionLime.Rating = {};
window.FashionLime.Constants = {};
window.FashionLime.Shared = {};
window.FashionLime.Validation = {};
window.FashionLime.Devise = {};
window.FashionLime.Newsletter = {};
window.FashionLime.PaymentInfo = {};

window.FashionLime.href = 'https://fashionlime.bg';

// Merchant
window.FashionLime.Merchant = {};
window.FashionLime.Merchant.Merchant = {};
window.FashionLime.Merchant.Order = {};
window.FashionLime.Merchant.OrderReturn = {};
window.FashionLime.Merchant.Shipment = {};
window.FashionLime.Merchant.PaymentType = {};
window.FashionLime.Merchant.ProductImport = {};
window.FashionLime.Merchant.ProductPicturesImport = {};
window.FashionLime.Merchant.Product = {};
window.FashionLime.Merchant.ProductCollection = {};
window.FashionLime.Merchant.SizeChart = {};

// Admin
window.FashionLime.Admin = {};
window.FashionLime.Admin.User = {};
window.FashionLime.Admin.Campaign = {};
window.FashionLime.Admin.OutfitDecoration = {};


// Set moment locale
(function() {
  moment.locale('bg');
})();

$(function() {
  FashionLime.Common.utils.setupHistoryOnPopState();
});
