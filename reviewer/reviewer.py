#!/usr/bin/env python3

from builders import *
from expression import *
from global_vars import *
from statements.assume import Assume
from statements.call import Call
from statements.require import Require
from statements.returns import Returns
from statements.sends import Sends
from statements.sets import Sets 
from statements.split import Split 

from function_aggregate import aggregate_function
from expression_builder import build_wrap, function_argument, NamedConstantBuilder
import expression_builders.builder_factory_implementation as builder_factory_implementation
from expressions.indexed import Index

import sys

building = True
builder_factory_implementation.init()

class Collection(object):
  def __init__(self):
    pass

class PredicateApplication(object):
  def __init__(self):
    pass

class Blockchain(Expression):
  def __init__(self):
    pass

  def type_(self):
    return 'undefined'
  
  def append_to(self, output, level):
    output.append('blockchain()')

  def substitute(self, sustitution:dict) -> Expression:
    return self

class BlockchainBuilder(ExpressionBuilder):
  def __init__(self):
    pass

  def build(self):
    return Blockchain()

blockchain = BlockchainBuilder()

def require(predicate) -> Require:
  return Require(build_wrap(predicate))

def call(function) -> Call:
  return Call(function)

def assume(predicate) -> Assume:
  return Assume(build_wrap(predicate))

def returns(expression) -> Returns:
  return Returns(build_wrap(expression))

def sets(destination, value) -> Sets:
  return Sets(build_wrap(destination), build_wrap(value))

def sends(amount: Expression, destination:Expression) -> Sends:
  return Sends(build_wrap(amount), build_wrap(destination))

def split(predicate: Expression, true_statements, false_statements) -> Split:
  return Split(build_wrap(predicate), true_statements, false_statements)

def named_value(expression:Expression, format_str:str, *format_args:Expression) -> Expression:
  return NamedValue(expression, format_str, *[build_wrap(arg) for arg in format_args])

def index() -> Index:
  return Index()

storage_function = FunctionCallBuilderName()

predicate_function = FunctionCallBuilderName()

contract_function = FunctionCallBuilderName()

named_constant = NamedConstantBuilder()

# --------------------------------------------------------------------------

token_whitelist = storage_function.token_whitelist('obj').build()

contains = predicate_function.contains('obj', 'value').build()

result_ok = predicate_function.result_ok('result').build()

is_empty = predicate_function.is_empty('obj').build()

ceil = predicate_function.ceil('value').build()

is_contract = predicate_function.is_contract('address', 'type').build()

egld_value = contract_function.egld_value('obj').build()

get_caller = contract_function.get_caller('obj').build()

has_tokens = predicate_function.has_tokens('address', 'token_id', 'nonce', 'amount').build()

system_contract = contract_function.system_contract('address').build()

returned_amount = fn.returned_amount('result').build()

owner_address = fn.owner_address('obj').build()

current_contract = fn.current_contract('obj').build()

egld = fn.egld().build()

# TODO: Unused
def require_token_in_whitelist_def() -> Function:
  obj = function_argument('obj')
  token_id = function_argument('token_id')
  return (
      fn.require_token_in_whitelist(obj, token_id)
        .statements(
          require(obj.token_whitelist().contains(token_id))
        )
        .build()
  )
require_token_in_whitelist = require_token_in_whitelist_def()

rsum = aggregate_function('rsum', arguments = [function_argument('value')])

def weighted_average_def() -> Function:
  dataset = function_argument('dataset')
  idx = index()
  return (
      fn.weighted_average('obj', dataset)
        .statements(
          assume(rsum[idx](dataset[idx].weight) > 0),
          returns(named_value(
              rsum[idx](dataset[idx].value * dataset[idx].weight) / rsum[idx](dataset[idx].weight),
              ['weighted_average(', ', ', ')'],
              dataset[idx].value,
              dataset[idx].weight
          ))
        ).build()
  )
weighted_average = weighted_average_def()

def weighted_average_ceil_def() -> Function:
  dataset = function_argument('dataset')
  idx = index()
  return (
      fn.weighted_average_ceil('obj', dataset)
        .statements(
          assume(rsum[idx](dataset[idx].weight) > 0),
          returns(named_value(
              ceil(rsum[idx](dataset[idx].value * dataset[idx].weight) / rsum[idx](dataset[idx].weight)),
              ['weighted_average_ceil(', ', ', ')'],
              dataset[idx].value,
              dataset[idx].weight
            ))
        )
        .build()
  )
weighted_average_ceil = weighted_average_ceil_def()

is_fraction_of = predicate_function.is_fraction_of('part', 'total').build()

def rule_of_three_def() -> Function:
  part = function_argument('part')
  total = function_argument('total')
  value = function_argument('value')

  return (
      fn.rule_of_three('obj', part, total, value)
        .statements(
          assume(total != 0),
          assume(is_fraction_of(part, total)),
          returns(named_value(
            (part * value) / total,
            ['', '%'],
            value
          ))
        )
        .build()
  )
rule_of_three = rule_of_three_def()

def rule_of_three_non_zero_result_def() -> Function:
  part = function_argument('part')
  total = function_argument('total')
  value = function_argument('value')

  result = named_value(
            (part * value) / total,
            ['', '%'],
            value
          )

  return (
      fn.rule_of_three_non_zero_result('obj', part, total, value)
        .statements(
          require(result != 0),
          assume(total != 0),
          assume(is_fraction_of(part, total)),
          returns(result)
        )
        .build()
  )
rule_of_three_non_zero_result = rule_of_three_non_zero_result_def()

def esdt_system_sc_proxy_def() -> Function:
  sc_address = function_argument('sc_address')

  return (
      fn.esdt_system_sc_proxy('obj', sc_address)
        .statements(
          assume(is_contract(sc_address, 'system')),
          returns(system_contract(sc_address))
        )
        .build()
  )
esdt_system_sc_proxy = esdt_system_sc_proxy_def()

dual_yield_token_id = storage_function.dual_yield_token_id('obj').build()

def issue_callback_def() -> Function:
  result = function_argument('result')
  obj = function_argument('obj')

  return (
      fn.issue_callback(obj, result)
        .statements(
          split(
              result_ok(result),
              sets(obj.dual_yield_token_id(), result),
              sends(returned_amount(result), blockchain.owner_address())
          )
        )
        .build()
  )
issue_callback = issue_callback_def()

def register_and_set_all_roles_def() -> Function:
  obj = function_argument('obj')
  egld_amount = function_argument('egld_amount')
  print([obj])
  print('*' * 80)
  return (
    fn_with_callback.register_and_set_all_roles(
        obj,
        egld_amount,
        'token_display_name',
        'token_ticker',
        'token_type',
        'decimals',
      ).statements(
        assume(has_tokens(blockchain.current_contract(), egld(), 0, egld_amount)),
        sends(egld_amount, obj)
      )
      .build()
  )
register_and_set_all_roles = register_and_set_all_roles_def()

ESDT_SYSTEM_SC_ADDRESS_ARRAY = named_constant.ESDT_SYSTEM_SC_ADDRESS_ARRAY('000000000000000000010000000000000000000000000000000000000002ffff')
META_SFT_TOKEN_TYPE_NAME = named_constant.META_SFT_TOKEN_TYPE_NAME('META')

def issue_dual_yield_token_def() -> Endpoint:
  obj = function_argument('obj')
  token_display_name = function_argument('token_display_name')
  token_ticker = function_argument('token_ticker')
  num_decimals = function_argument('num_decimals')
  return (
    endpoint.issue_dual_yield_token(
        obj,
        token_display_name,
        token_ticker,
        num_decimals
    )
    .only_owner()
    .payable('EGLD')
    .statements(
      require(obj.dual_yield_token_id().is_empty()),
      call(register_and_set_all_roles
              .with_callback(obj.issue_callback(obj.get_caller()))
              .call(
                  obj.esdt_system_sc_proxy(ESDT_SYSTEM_SC_ADDRESS_ARRAY),
                  obj.egld_value(),
                  token_display_name,
                  token_ticker,
                  META_SFT_TOKEN_TYPE_NAME,
                  num_decimals
              )
          
      ),
    )
    .build()
  )
issue_dual_yield_token = issue_dual_yield_token_def()

"""
[elrond_wasm::module]
pub trait DualYieldTokenModule: token_merge::TokenMergeModule {
  [only_owner]
  [payable("EGLD")][endpoint(issueDualYieldToken)]
  issue_dual_yield_token(self, token_display_name, token_ticker, num_decimals) -> AsyncCall
    - requires
      - is_empty(dual_yield_token_id())
    - esdt_system_sc_proxy(ESDT_SYSTEM_SC_ADDRESS_ARRAY).register_and_set_all_roles(
          egld_value(),
          token_display_name,
          token_ticker,
          META_SFT_TOKEN_TYPE_NAME,
          num_decimals)
      - callback=issue_callback(get_caller())
        - if ok
          - sets
            - dual_yield_token_id() = *result
        - if err
          - sends
            - returned amount to get_caller()

  require_dual_yield_token(self, token_id)
    - requires
      - token_id == dual_yield_token_id()

  require_all_payments_dual_yield_tokens(self, payments)
    - requires
      - payments[..].token_identifier == dual_yield_token_id()

  create_dual_yield_tokens(
            self,
            lp_farm_token_nonce,
            lp_farm_token_amount,
            staking_farm_token_nonce,
            staking_farm_token_amount
        ) -> EsdtTokenPayment
    - assumes
      - the contract holds lp_farm_token_amount
        of (lp_farm_token_id(), lp_farm_token_nonce)
      - lp_farm_token_amount != 0
      - the contract holds staking_farm_token_amount
        of (staking_farm_token_id(), staking_farm_token_nonce)
      - staking_farm_token_amount != 0
    - sets
      - new_attributes = DualYieldTokenAttributes {
          lp_farm_token_nonce = lp_farm_token_nonce,
          lp_farm_token_amount = lp_farm_token_amount,
          staking_farm_token_nonce = staking_farm_token_nonce,
          staking_farm_token_amount = staking_farm_token_amount
      }
    - new_attributes.get_total_dual_yield_tokens_for_position()
      - returns
        - new_attributes.staking_farm_token_amount
    - mints
      - new_attributes.staking_farm_token_amount of dual_yield_token_id()
        with new_attributes as new_token_nonce
    - returns
      - (dual_yield_token_id(), new_token_nonce, new_attributes.staking_farm_token_amount)

  create_and_send_dual_yield_tokens(
          self,
          destination,
          lp_farm_token_nonce,
          lp_farm_token_amount,
          staking_farm_token_nonce,
          staking_farm_token_amount,
        ) -> EsdtTokenPayment
    - assumes
      - the contract holds lp_farm_token_amount
        of (lp_farm_token_id(), lp_farm_token_nonce)
      - lp_farm_token_amount != 0
      - the contract holds staking_farm_token_amount
        of (staking_farm_token_id(), staking_farm_token_nonce)
      - staking_farm_token_amount != 0
    - sets
      - new_attributes = DualYieldTokenAttributes {
          lp_farm_token_nonce = lp_farm_token_nonce,
          lp_farm_token_amount = lp_farm_token_amount,
          staking_farm_token_nonce = staking_farm_token_nonce,
          staking_farm_token_amount = staking_farm_token_amount
      }
    - mints
      - new_attributes.staking_farm_token_amount of dual_yield_token_id()
        with new_attributes
        as new_token_nonce
    - sends
      - (dual_yield_token_id(), new_token_nonce, new_attributes.staking_farm_token_amount)
        to destination
    - returns
      - (dual_yield_token_id(), new_token_nonce, new_attributes.staking_farm_token_amount)
    --------------------------
    - create_dual_yield_tokens(
              self,
              lp_farm_token_nonce,
              lp_farm_token_amount,
              staking_farm_token_nonce,
              staking_farm_token_amount
          ) -> EsdtTokenPayment
      - assumes
        - the contract holds lp_farm_token_amount
          of (lp_farm_token_id(), lp_farm_token_nonce)
        - lp_farm_token_amount != 0
        - the contract holds staking_farm_token_amount
          of (staking_farm_token_nonce, staking_farm_token_amount)
        - staking_farm_token_amount != 0
      - sets
        - new_attributes = DualYieldTokenAttributes {
            lp_farm_token_nonce = lp_farm_token_nonce,
            lp_farm_token_amount = lp_farm_token_amount,
            staking_farm_token_nonce = staking_farm_token_nonce,
            staking_farm_token_amount = staking_farm_token_amount
        }
      - new_attributes.get_total_dual_yield_tokens_for_position()
        - returns
          - new_attributes.staking_farm_token_amount
      - mints
        - new_attributes.staking_farm_token_amount of dual_yield_token_id()
          with new_attributes
          as new_token_nonce
      - returns
        - (dual_yield_token_id(), new_token_nonce, new_attributes.staking_farm_token_amount)
    - sends
      - (dual_yield_token_id(), new_token_nonce, new_attributes.staking_farm_token_amount)
        to destination
    - returns
      - (dual_yield_token_id(), new_token_nonce, new_attributes.staking_farm_token_amount)

  burn_dual_yield_tokens(self, sft_nonce, amount)
    - burns
      - (dual_yield_token_id(), sft_nonce, amount)

  get_dual_yield_token_attributes(self, dual_yield_token_nonce) -> DualYieldTokenAttributes
    - assumes
      - (dual_yield_token_id(), dual_yield_token_nonce) is valid
    - returns
      - DualYieldTokenAttributes(dual_yield_token_id(), dual_yield_token_nonce)

  get_lp_farm_token_amount_equivalent(self, attributes, amount) -> BigUint
    - requires
      - attributes.lp_farm_token_amount% != 0
    - assumes
      - amount measures dual_yield_token_id() with attributes
    - returns
      - attributes.lp_farm_token_amount%
    ------------------------------
    - assumes
      - amount measures dual_yield_token_id() with attributes
    - attributes.get_total_dual_yield_tokens_for_position()
      - returns
        - attributes.staking_farm_token_amount
    - rule_of_three_non_zero_result(self,
          amount,
          attributes.staking_farm_token_amount,
          attributes.lp_farm_token_amount) -> BigUint
      - requires
        - attributes.lp_farm_token_amount% != 0
      - assumes
        - attributes.staking_farm_token_amount != 0
          - invariant
      - returns
        - attributes.lp_farm_token_amount%
          = (amount * attributes.lp_farm_token_amount)
            / attributes.staking_farm_token_amount
    - returns
      - attributes.lp_farm_token_amount%

  get_staking_farm_token_amount_equivalent(self, amount) -> BigUint
    - assumes
      - amount measures dual_yield_token_id() with some attributes
    - returns
      - attributes.staking_farm_token_amount%=amount
}
"""

def print_function(f):
  print(f.header())
  defs = f.definitions()
  if defs:
    print([defs])
  summary = f.summary()
  if summary:
    print(summary)
    print('  ' + '-' * 30)
  print(f.details())

def main(argv):
  global building
  building = False
  functions = [
      require_token_in_whitelist,
      weighted_average,
      weighted_average_ceil,
      rule_of_three,
      rule_of_three_non_zero_result,
      esdt_system_sc_proxy,
      issue_callback,
      register_and_set_all_roles,
      issue_dual_yield_token
  ]
  for f in functions:
    print_function(f)
    print()

if __name__ == "__main__":
  main(sys.argv[1:])
