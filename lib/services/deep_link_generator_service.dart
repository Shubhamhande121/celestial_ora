// class DeepLinkGenerator {
//   // Generate web URL for sharing
//   static String generateWebProductUrl(String productId) {
//     return "https://sadiyaenterprises.in/product/$productId";
//   }
  
//   // Generate custom scheme URL (works without internet)
//   static String generateAppProductUrl(String productId) {
//     return "organicsaga://product/$productId";
//   }
  
//   // Generate both URLs for sharing options
//   static Map<String, String> generateAllProductUrls(String productId) {
//     return {
//       'web_url': generateWebProductUrl(productId),
//       'app_url': generateAppProductUrl(productId),
//     };
//   }
  
//   // Generate shareable message with product info
//   static String generateShareMessage(String productId, String productName) {
//     final webUrl = generateWebProductUrl(productId);
//     final appUrl = generateAppProductUrl(productId);
    
//     return '''
// Check out "$productName" on Organic Saga!

// 🌱 Web Link: $webUrl
// 📱 App Link: $appUrl

// Download the app: [Your App Store Link]
//     ''';
//   }
// }