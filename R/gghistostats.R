#' @title Histogram for distribution of a numeric variable
#' @name gghistostats
#' @aliases gghistostats
#' @description Histogram with statistical details from one-sample test included
#'   in the plot as a subtitle.
#' @author Indrajeet Patil
#'
#' @param bar.measure Character describing what value needs to be represented as
#'   height in the bar chart. This can either be `"count"`, which shows number
#'   of points in bin, or `"density"`, which density of points in bin, scaled to
#'   integrate to 1, or "`proportion`", which shows relative frequencies of
#'   observations in each bin, or "`mix`", which shows *both* count and
#'   proportion in the same plot.
#' @param fill.gradient Logical decides whether color fill gradient is to be
#'   displayed (Default: `FALSE`). If `FALSE`, the legend and the color gradient
#'   will also be removed. The default is set to `FALSE` because the gradient
#'   provides redundant information in light of y-axis labels.
#' @param low.color,high.color Colors for low and high ends of the gradient.
#'   Defaults are colorblind-friendly.
#' @param bar.fill If `fill.gradient = FALSE`, then `bar.fill` decides which
#'   color will uniformly fill all the bars in the histogram (Default:
#'   `"grey50"`).
#' @param binwidth The width of the histogram bins. Can be specified as a
#'   numeric value, or a function that calculates width from `x`. The default is
#'   to use the `max(x) - min(x) / sqrt(N)`. You should always check this value
#'   and explore multiple widths to find the best to illustrate the stories in
#'   your data.
#' @inheritParams theme_ggstatsplot
#' @inheritParams subtitle_t_onesample
#' @inheritParams histo_labeller
#' @inheritParams ggbetweenstats
#'
#' @import ggplot2
#'
#' @importFrom dplyr select bind_rows summarize mutate mutate_at mutate_if
#' @importFrom dplyr group_by n arrange
#' @importFrom jmv ttestOneS
#' @importFrom WRS2 onesampb
#' @importFrom scales percent
#' @importFrom crayon green blue yellow red
#'
#' @examples
#' 
#' # most basic function call with the defaults
#' # this is the only function where data argument can be `NULL`.
#' ggstatsplot::gghistostats(
#'   x = ToothGrowth$len,
#'   xlab = "Tooth length",
#'   centrality.para = "median"
#' )
#' 
#' # a detailed function call
#' ggstatsplot::gghistostats(
#'   data = datasets::iris,
#'   x = Sepal.Length,
#'   bar.measure = "mix",
#'   type = "p",
#'   bf.message = TRUE,
#'   caption = substitute(paste(italic("Note"), ": Iris dataset by Fisher.")),
#'   bf.prior = 0.8,
#'   test.value = 3,
#'   test.value.line = TRUE,
#'   binwidth = 0.10,
#'   bar.fill = "grey50"
#' )
#' @seealso \code{\link{grouped_gghistostats}}
#'
#' @references
#' \url{https://cran.r-project.org/package=ggstatsplot/vignettes/gghistostats.html}
#'
#' @export

# function body
gghistostats <- function(data = NULL,
                         x,
                         binwidth = NULL,
                         bar.measure = "count",
                         xlab = NULL,
                         title = NULL,
                         subtitle = NULL,
                         caption = NULL,
                         type = "parametric",
                         test.value = 0,
                         bf.prior = 0.707,
                         bf.message = FALSE,
                         robust.estimator = "onestep",
                         nboot = 100,
                         k = 2,
                         ggtheme = ggplot2::theme_bw(),
                         ggstatsplot.layer = TRUE,
                         fill.gradient = FALSE,
                         low.color = "#0072B2",
                         high.color = "#D55E00",
                         bar.fill = "grey50",
                         results.subtitle = TRUE,
                         centrality.para = "mean",
                         centrality.color = "blue",
                         centrality.size = 1.0,
                         centrality.linetype = "dashed",
                         centrality.line.labeller = TRUE,
                         centrality.k = 2,
                         test.value.line = FALSE,
                         test.value.color = "black",
                         test.value.size = 1.0,
                         test.value.linetype = "dashed",
                         test.line.labeller = TRUE,
                         test.k = 0,
                         messages = TRUE) {
  # if data is not available then don't display any messages
  if (is.null(data)) {
    messages <- FALSE
  }

  # if no color fill is to be displayed, set low and high color to white
  if (!isTRUE(fill.gradient)) {
    low.color <- bar.fill
    high.color <- bar.fill
  }

  # ================================= dataframe ==============================
  # preparing a dataframe out of provided inputs
  if (!is.null(data)) {
    # preparing labels from given dataframe
    lab.df <- colnames(dplyr::select(
      .data = data,
      !!rlang::enquo(x)
    ))
    # if xlab is not provided, use the variable x name
    if (is.null(xlab)) {
      xlab <- lab.df[1]
    }

    # if dataframe is provided
    data <-
      dplyr::select(
        .data = data,
        x = !!rlang::enquo(x)
      )
  } else {
    # if vectors are provided
    data <-
      base::cbind.data.frame(x = x)
  }

  # convert to a tibble and remove NAs from `x`
  data %<>%
    tibble::as_tibble(x = .) %>%
    dplyr::filter(.data = ., !is.na(x))

  # Adding some binwidth sanity checking
  if (is.null(binwidth)) {
    binwidth <- (max(data$x) - min(data$x)) / sqrt(length(data$x))
  }

  # ================ stats labels ==========================================

  if (isTRUE(results.subtitle)) {

    # preparing the BF message for NULL
    if (isTRUE(bf.message)) {
      bf.caption.text <-
        bf_one_sample_ttest(
          data = data,
          x = x,
          test.value = test.value,
          bf.prior = bf.prior,
          caption = caption,
          output = "caption",
          k = k
        )
    }

    # preparing the subtitle with statistical results
    subtitle <-
      subtitle_t_onesample(
        data = data,
        x = x,
        type = type,
        test.value = test.value,
        bf.prior = bf.prior,
        robust.estimator = robust.estimator,
        nboot = nboot,
        k = k,
        messages = messages
      )
  }

  # ============================= plot ====================================

  # preparing the basic layout of the plot based on whether counts or density
  # information is needed

  if (bar.measure == "count") {

    # only counts
    plot <- ggplot2::ggplot(
      data = data,
      mapping = ggplot2::aes(x = x)
    ) +
      ggplot2::stat_bin(
        col = "black",
        alpha = 0.7,
        binwidth = binwidth,
        na.rm = TRUE,
        mapping = ggplot2::aes(
          y = ..count..,
          fill = ..count..
        )
      ) +
      ggplot2::scale_fill_gradient(
        name = "count",
        low = low.color,
        high = high.color
      )
  } else if (bar.measure == "proportion") {

    # only proportion
    plot <- ggplot2::ggplot(
      data = data,
      mapping = ggplot2::aes(x = x)
    ) +
      ggplot2::stat_bin(
        col = "black",
        alpha = 0.7,
        binwidth = binwidth,
        na.rm = TRUE,
        mapping = ggplot2::aes(
          y = ..count.. / sum(..count..),
          fill = ..count.. / sum(..count..)
        )
      ) +
      ggplot2::scale_fill_gradient(
        name = "proportion",
        low = low.color,
        high = high.color,
        labels = percent
      ) +
      ggplot2::scale_y_continuous(labels = scales::percent) +
      ggplot2::ylab("proportion")
  } else if (bar.measure == "density") {

    # only density
    plot <- ggplot2::ggplot(
      data = data,
      mapping = ggplot2::aes(x = x)
    ) +
      ggplot2::stat_bin(
        col = "black",
        alpha = 0.7,
        binwidth = binwidth,
        na.rm = TRUE,
        mapping = ggplot2::aes(
          y = ..density..,
          fill = ..density..
        )
      ) +
      ggplot2::scale_fill_gradient(
        name = "density",
        low = low.color,
        high = high.color
      )
  } else if (bar.measure == "mix") {

    # all things combined
    plot <- ggplot2::ggplot(
      data = data,
      mapping = ggplot2::aes(x = x)
    ) +
      ggplot2::stat_bin(
        col = "black",
        alpha = 0.7,
        binwidth = binwidth,
        na.rm = TRUE,
        mapping = ggplot2::aes(
          y = ..count..,
          fill = ..count..
        )
      ) +
      ggplot2::scale_fill_gradient(
        name = "count",
        low = low.color,
        high = high.color
      ) +
      ggplot2::scale_y_continuous(
        sec.axis = ggplot2::sec_axis(
          trans = ~ . / nrow(x = data),
          labels = scales::percent,
          name = "proportion"
        )
      ) +
      ggplot2::ylab("count") +
      ggplot2::guides(fill = FALSE)
  }

  # if bayes factor message needs to be displayed
  if (isTRUE(results.subtitle) &&
    type %in% c("parametric", "p") && isTRUE(bf.message)) {
    caption <- bf.caption.text
  }

  # adding the theme and labels
  plot <- plot +
    ggstatsplot::theme_ggstatsplot(
      ggtheme = ggtheme,
      ggstatsplot.layer = ggstatsplot.layer
    ) +
    ggplot2::labs(
      x = xlab,
      title = title,
      subtitle = subtitle,
      caption = caption
    )

  # ====================== centrality line and label ========================

  # computing statistics needed for displaying labels
  y_label_pos <- median(
    x = ggplot2::layer_scales(plot)$y$range$range,
    na.rm = TRUE
  )

  # using custom function for adding labels
  plot <- histo_labeller(
    plot = plot,
    x = data$x,
    y.label.position = y_label_pos,
    centrality.para = centrality.para,
    centrality.color = centrality.color,
    centrality.size = centrality.size,
    centrality.linetype = centrality.linetype,
    centrality.line.labeller = centrality.line.labeller,
    centrality.k = centrality.k,
    test.value = test.value,
    test.value.line = test.value.line,
    test.value.color = test.value.color,
    test.value.size = test.value.size,
    test.value.linetype = test.value.linetype,
    test.line.labeller = test.line.labeller,
    test.k = test.k
  )

  # if no color fill gradient is used, then remove the legend
  if (!isTRUE(fill.gradient)) {
    plot <- plot +
      ggplot2::theme(legend.position = "none")
  }

  # ============================= messages =================================
  #
  # display normality test result as a message
  if (isTRUE(messages)) {
    normality_message(
      x = data$x,
      lab = lab.df[1],
      k = k,
      output = "message"
    )
  }

  # return the final plot
  return(plot)
}
