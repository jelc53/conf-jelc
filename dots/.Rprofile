utils::assignInNamespace(
  "q",
  function(save = "no", status = 0, runLast = TRUE)
  {
    .Internal(quit(save, status, runLast))
  },
  "base"
)

wide <- function(w=Sys.getenv("COLUMNS")) {
  options(width=as.integer(w))
}

# default to Cairo for graphics (for semi-transparency)
setHook(packageEvent("grDevices", "onLoad"),
function(...) grDevices::X11.options(type='cairo'))
options(device='x11')

options(repos=structure(c(CRAN="https://ftp.osuosl.org/pub/cran/")))
# print tibbles using glimpse
print.tbl_df <- function(x, ...) glimpse(x, ...)
