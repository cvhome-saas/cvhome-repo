app = "cvhome-repo"
projects = [
  "store-core/store-core-gateway",
  "store-core/core-auth",
  "store-core/manager",
  "store-core/subscription",
  "store-core/store-ui",
  "store-core/welcome-ui",

  "store-pod/store-pod-gateway",
  "store-pod/merchant",
  "store-pod/content",
  "store-pod/catalog",
  "store-pod/order",
  "store-pod/landing-ui",
  "store-pod/merchant-ui",
  "store-pod/store-pod-saas-gateway"
]
cvhome-config = {
  "trackUsage" : "false",
  "usageExecededAction" : "continue",
  "nonRenewedSubscriptionAction" : "continue"
}
smtp-config = {
  "host" : "",
  "username" : "",
  "password" : "",
  "port" : ""
}
stripe-config = {
  "stripeKey" : "",
  "stripeWebhockSigningKey" : ""
}
pods-config = [
  {
    index : 0
    id : "1"
    name : "default",
    size : "large"
  },
  # {
  #   index : 1
  #   id : "2"
  #   name : "o-21f023932bc66470c104b76f",
  #   org : "21f023932bc66470c104b76f"
  #   size : "x-large",
  # }
]