loginAPIToken <- function(){
  email    <- readline(prompt = "Enter email: ")
  password <- readline(prompt = "Enter password: ")
  getAPIToken(email,password)
}