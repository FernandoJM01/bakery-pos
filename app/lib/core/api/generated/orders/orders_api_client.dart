// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/branch_tickets.dart';
import '../models/customer.dart';
import '../models/customer_create.dart';
import '../models/customer_detail.dart';
import '../models/customer_order.dart';
import '../models/customer_update.dart';
import '../models/get_v1_customers_response.dart';
import '../models/get_v1_orders_response.dart';
import '../models/local_date.dart';
import '../models/order_create.dart';
import '../models/order_update.dart';
import '../models/pick_list.dart';
import '../models/v1_orders_order_id_pause_request_body.dart';
import '../models/v1_orders_order_id_skips_request_body.dart';

part 'orders_api_client.g.dart';

@RestApi()
abstract class OrdersApiClient {
  factory OrdersApiClient(Dio dio, {String? baseUrl}) = _OrdersApiClient;

  /// Customers by name, or found by part of the name or the phone
  @GET('/v1/customers')
  Future<GetV1CustomersResponse> listCustomers({@Query('q') String? q});

  /// Creates a customer; writes `customer.created`
  @POST('/v1/customers')
  Future<Customer> createCustomer({@Body() required CustomerCreate body});

  /// A customer with balance, orders and recent balance entries
  @GET('/v1/customers/{customerId}')
  Future<CustomerDetail> getCustomer({
    @Path('customerId') required String customerId,
  });

  /// Changes a customer; writes `customer.updated`
  @PATCH('/v1/customers/{customerId}')
  Future<Customer> updateCustomer({
    @Path('customerId') required String customerId,
    @Body() required CustomerUpdate body,
  });

  /// Standing orders and pre-orders in the callers branches
  @GET('/v1/orders')
  Future<GetV1OrdersResponse> listOrders({
    @Query('customerId') String? customerId,
    @Query('branchId') String? branchId,
  });

  /// Creates an order and its tickets; writes `order.created`
  @POST('/v1/orders')
  Future<CustomerOrder> createOrder({@Body() required OrderCreate body});

  /// Order tickets of the device's branch, from yesterday to the last day kept, for offline pickup
  @GET('/v1/orders/tickets')
  Future<BranchTickets> listBranchTickets();

  /// Totals per product for the baker and the tickets for the counter, for one day (M7.4)
  @GET('/v1/orders/pick-list')
  Future<PickList> getPickList({
    @Query('branchId') required String branchId,
    @Query('date') required LocalDate date,
  });

  /// An order
  @GET('/v1/orders/{orderId}')
  Future<CustomerOrder> getOrder({@Path('orderId') required String orderId});

  /// Changes an order; tickets not picked up are rebuilt (G9)
  @PUT('/v1/orders/{orderId}')
  Future<CustomerOrder> updateOrder({
    @Path('orderId') required String orderId,
    @Body() required OrderUpdate body,
  });

  /// Skips one date; its ticket, if pending, is skipped
  @POST('/v1/orders/{orderId}/skips')
  Future<CustomerOrder> skipOrderDate({
    @Path('orderId') required String orderId,
    @Body() required V1OrdersOrderIdSkipsRequestBody body,
  });

  /// Brings a skipped date back
  @DELETE('/v1/orders/{orderId}/skips/{date}')
  Future<CustomerOrder> unskipOrderDate({
    @Path('orderId') required String orderId,
    @Path('date') required LocalDate date,
  });

  /// Pauses between two dates, or from a date with no end
  @POST('/v1/orders/{orderId}/pause')
  Future<CustomerOrder> pauseOrder({
    @Path('orderId') required String orderId,
    @Body() required V1OrdersOrderIdPauseRequestBody body,
  });

  /// Ends a pause
  @POST('/v1/orders/{orderId}/resume')
  Future<CustomerOrder> resumeOrder({@Path('orderId') required String orderId});

  /// Ends an order; no more tickets are made
  @POST('/v1/orders/{orderId}/end')
  Future<CustomerOrder> endOrder({@Path('orderId') required String orderId});
}
