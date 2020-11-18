/*
 * Copyright 2020 HM Revenue & Customs
 *
 */

package uk.gov.hmrc.perftests.example

import uk.gov.hmrc.performance.simulation.PerformanceTestRunner
import uk.gov.hmrc.perftests.example.ExampleRequests._

class ExampleSimulation extends PerformanceTestRunner {

  setup("home-page", "Home Page") withRequests navigateToHomePage

  setup("post-vat-return-period", "Post vat return period") withRequests postVatReturnPeriod

  setup("get-turnover-page", "Get turnover page") withRequests getTurnoverPage

  runSimulation()
}
