# terra is optional in EJAM, but Ubuntu release checks exercise its native
# libraries explicitly so a successful hard-dependency install cannot mask it.
message("terra version: ", utils::packageVersion("terra"))
stopifnot(utils::packageVersion("terra") >= "1.9.50")
message("GDAL/PROJ/GEOS versions:")
print(terra::gdal(lib = "all"))

# Exercise PROJ's coordinate database as well as loading the shared library.
point <- terra::vect(data.frame(x = 0, y = 45), geom = c("x", "y"),
                     crs = "EPSG:4326")
projected <- terra::crds(terra::project(point, "EPSG:3857"))
stopifnot(abs(projected[1, 1]) < 1, abs(projected[1, 2] - 5621521.486) < 1)

# Exercise GDAL's GeoTIFF driver with a small file, without external data.
local({
  path <- tempfile(fileext = ".tif")
  on.exit(unlink(path))
  raster <- terra::rast(nrows = 2, ncols = 2, xmin = 0, xmax = 2,
                        ymin = 0, ymax = 2, crs = "EPSG:4326")
  terra::values(raster) <- 1:4
  terra::writeRaster(raster, path)
  stopifnot(identical(as.numeric(terra::values(terra::rast(path))), as.numeric(1:4)))
})
message("terra projection and GeoTIFF round trip OK")
