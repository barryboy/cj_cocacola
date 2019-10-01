job_progress <- function(condition)
  if (condition) {
    cat('\rRunning')
    Sys.sleep(.5)
    cat('.')
    Sys.sleep(.5)
    cat('.')
    Sys.sleep(.5)
    cat('.')
    Sys.sleep(.5)
    cat('\rRunning     \r')
    flush.console()
  } else {
    cat('\r              \rDone!\n')
  }