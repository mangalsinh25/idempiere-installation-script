-- The purpose of this script is to help you create views that are easily used inside a BI or analytics tool.

--Missing Tables
-- tax
-- locator
-- document type
-- price list
-- currency
-- user

----- Section 2 ----- Create the views needed to resolve keys into human readable words
DROP VIEW IF EXISTS bi_production_line;
DROP VIEW IF EXISTS bi_production;
DROP VIEW IF EXISTS bi_request;
DROP VIEW IF EXISTS bi_requisition_line;
DROP VIEW IF EXISTS bi_requisition;
DROP VIEW IF EXISTS bi_inout_line;
DROP VIEW IF EXISTS bi_inout;
DROP VIEW IF EXISTS bi_invoice_line;
DROP VIEW IF EXISTS bi_invoice;
DROP VIEW IF EXISTS bi_order_line;
DROP VIEW IF EXISTS bi_order;
DROP VIEW IF EXISTS bi_product;
DROP VIEW IF EXISTS bi_charge;
DROP VIEW IF EXISTS bi_warehouse;
DROP VIEW IF EXISTS bi_user;
DROP VIEW IF EXISTS bi_bploc;
DROP VIEW IF EXISTS bi_location;
DROP VIEW IF EXISTS bi_bpartner;
DROP VIEW IF EXISTS bi_uom;
DROP VIEW IF EXISTS bi_tax_category;
DROP VIEW IF EXISTS bi_org;
DROP VIEW IF EXISTS bi_client;

CREATE VIEW bi_client AS
SELECT c.name AS client_name,
c.ad_client_id as client_id
FROM ad_client c;
SELECT 'c.'||column_name||',' as client FROM information_schema.columns WHERE  table_name   = 'bi_client';

CREATE VIEW bi_org AS
SELECT 
o.name AS org_name,
o.value AS org_search_key,
o.ad_org_id as org_id,
o.isactive AS org_active
FROM ad_org o
WHERE o.issummary = 'N'::bpchar;
SELECT 'o.'||column_name||',' as org FROM information_schema.columns WHERE  table_name   = 'bi_org';

CREATE VIEW bi_tax_category as
SELECT
c.*,
-- assuming no org needed
tc.c_taxcategory_id as tax_category_id,
tc.name as tax_category_name,
tc.description as tax_category_description
from c_taxcategory tc
join bi_client c on tc.ad_client_id = c.client_id;
SELECT 'tc.'||column_name||',' as tax_category FROM information_schema.columns WHERE  table_name   = 'bi_tax_category';

CREATE VIEW bi_uom AS
SELECT uom.c_uom_id as uom_id,
c.*,
-- assuming no org needed
uom.name AS uom_name, 
uom.uomsymbol AS uom_search_key, 
uom.isactive AS uom_active
FROM c_uom uom
JOIN bi_client c on uom.ad_client_id=c.client_id;
SELECT 'uom.'||column_name||',' as uom FROM information_schema.columns WHERE  table_name   = 'bi_uom';

CREATE VIEW bi_bpartner AS
SELECT
c.*,
-- assuming no org needed
bp.c_bpartner_id as bpartner_id,
bp.value AS bpartner_search_key,
bp.name AS bpartner_name,
bp.name2 AS bpartner_name2,
bp.created AS bpartner_created,
bp.updated as bpartner_updated,
bp.iscustomer AS bpartner_customer,
bp.isvendor AS bpartner_vendor,
bp.isemployee AS bpartner_employee
from c_bpartner bp
join bi_client c on bp.ad_client_id = c.client_id
join bi_org o on bp.ad_org_id = o.org_id
;
SELECT 'bp.'||column_name||',' as bpartner FROM information_schema.columns WHERE  table_name   = 'bi_bpartner';

CREATE VIEW bi_location AS
SELECT
l.c_location_id as loc_id,
l.address1 AS loc_address1,
l.address2 AS loc_address2,
l.address3 AS loc_address3,
l.address4 AS loc_address4,
l.city AS loc_city,
l.regionname AS loc_state,
country.countrycode AS loc_country_code,
country.name AS loc_country_name
FROM c_location l
JOIN c_country country ON l.c_country_id = country.c_country_id
;
SELECT 'loc.'||column_name||',' as loc FROM information_schema.columns WHERE  table_name   = 'bi_location';

CREATE VIEW bi_bploc AS
SELECT
c.*,
o.*,

bpl.c_bpartner_location_id as bpartner_location_id,

bp.bpartner_id,
bp.bpartner_search_key,
bp.bpartner_name,
bp.bpartner_name2,
bp.bpartner_created,
bp.bpartner_updated,
bp.bpartner_customer,
bp.bpartner_vendor,
bp.bpartner_employee,

bpl.name AS bploc_name,
bpl.created as bploc_created,
bpl.updated as bploc_updated,

loc.loc_address1 as bploc_address1,
loc.loc_address2 as bploc_address2,
loc.loc_address3 as bploc_address3,
loc.loc_address4 as bploc_address4,
loc.loc_city as bploc_city,
loc.loc_state as bploc_state,
loc.loc_country_code as bploc_country_code,
loc.loc_country_name as bploc_country_name

FROM c_bpartner_location bpl
JOIN bi_bpartner bp on bpl.c_bpartner_id = bp.bpartner_id
JOIN bi_client c ON bpl.ad_client_id = c.client_id
JOIN bi_org o on bpl.ad_org_id = o.org_id
join bi_location loc on bpl.c_location_id = loc.loc_id
;
SELECT 'bploc.'||column_name||',' as bploc FROM information_schema.columns WHERE  table_name   = 'bi_bploc';

CREATE VIEW bi_user AS
SELECT
c.*,
-- assuming no org needed
u.value as user_search_key,
u.name as user_name,
u.description as user_description,
u.email as user_email,
u.phone as user_phone,

bp.bpartner_search_key,
bp.bpartner_name,
bp.bpartner_name2,
bp.bpartner_created,
bp.bpartner_updated,
bp.bpartner_customer,
bp.bpartner_vendor,
bp.bpartner_employee,

bploc.bploc_name as user_bploc_name,
bploc.bploc_created as user_bploc_created,
bploc.bploc_updated as user_bploc_updated,
bploc.bploc_address1 as user_bploc_address1,
bploc.bploc_address2 as user_bploc_address2,
bploc.bploc_address3 as user_bploc_address3,
bploc.bploc_address4 as user_bploc_address4,
bploc.bploc_city as user_bploc_city,
bploc.bploc_state as user_bploc_state,
bploc.bploc_country_code as user_bploc_country_code,
bploc.bploc_country_name as user_bploc_country_name

FROM ad_user u
JOIN bi_client c on u.ad_client_id = c.client_id
JOIN bi_bpartner bp on u.c_bpartner_id = bp.bpartner_id
JOIN bi_bploc bploc on u.c_bpartner_location_id = bploc.bpartner_location_id
;
SELECT 'u.'||column_name||',' as user FROM information_schema.columns WHERE  table_name   = 'bi_user';

CREATE VIEW bi_warehouse AS
SELECT
c.*,
o.*,
w.m_warehouse_id as warehouse_id,
w.value as warehouse_search_key,
w.name as warehouse_name,
w.description as warehouse_description,
w.isactive as warehouse_active,
w.isintransit as warehouse_in_transit,
w.isdisallownegativeinv as warehouse_prevent_negative_inventory,

loc.loc_address1 as warehouse_loc_address1,
loc.loc_address2 as warehouse_loc_address2,
loc.loc_address3 as warehouse_loc_address3,
loc.loc_address4 as warehouse_loc_address4,
loc.loc_city as warehouse_loc_city,
loc.loc_state as warehouse_loc_state,
loc.loc_country_code as warehouse_loc_country_code,
loc.loc_country_name as warehouse_loc_country_name

FROM m_warehouse w
join bi_client c on w.ad_client_id = c.client_id
join bi_org o on w.ad_org_id = o.org_id
left join bi_location loc on w.c_location_id = loc.loc_id
;
SELECT 'wh.'||column_name||',' as warehouse FROM information_schema.columns WHERE  table_name   = 'bi_warehouse';

CREATE VIEW bi_charge AS
SELECT 
c.*,
chg.c_charge_id as charge_id,
chg.name AS charge_name,
chg.description AS charge_description,
chg.isactive as charge_active,
chg.created as charge_created,
chg.updated as charge_updated
FROM c_charge chg
JOIN bi_client c on chg.ad_client_id=c.client_id;
SELECT 'chg.'||column_name||',' as charge FROM information_schema.columns WHERE  table_name   = 'bi_charge';

CREATE VIEW bi_product AS
SELECT
c.*,
p.m_product_id as product_id,
p.value as product_search_key,
p.created as product_created,
p.updated as product_updated,
p.name as product_name,
p.description as product_description,
p.documentnote as product_document_note,
p.isactive as product_active,
prodtype.name as product_type,
pc.name as product_category_name,
uom.uom_name
from m_product p
join AD_Ref_List prodtype on p.producttype = prodtype.value AND prodtype.AD_Reference_ID=270
join m_product_category pc on p.m_product_category_id = pc.m_product_category_id
join bi_uom uom on p.c_uom_id = uom.uom_id
join bi_client c on p.ad_client_id = c.client_id
;
SELECT 'prod.'||column_name||',' as product FROM information_schema.columns WHERE  table_name   = 'bi_product';

CREATE VIEW bi_order AS
SELECT
c.*,
o.*,
ord.c_order_id as order_id,
ord.documentno as Order_DocumentNo,
dt.name as order_document_type,
ord.poreference as order_order_reference,
ord.description as order_description,
ord.datepromised as order_date_promised,
ord.dateordered as Order_date_ordered,
delrule.name as order_delivery_rule,
invrule.name as order_invoice_rule,
ord.priorityrule as order_priority,

ord.grandtotal as Order_Grand_total,
ord.issotrx as Order_Sales_Transaction,
ord.docstatus as Order_document_status,
ord.created as order_created,
ord.updated as order_updated,

bp.bpartner_search_key as ship_bpartner_search_key,
bp.bpartner_name as ship_bpartner_name,
bp.bpartner_name2 as ship_bpartner_name2,
bp.bpartner_created as ship_bpartner_created,
bp.bpartner_updated as ship_bpartner_updated,
bp.bpartner_customer as ship_bpartner_customer,
bp.bpartner_vendor as ship_bpartner_vendor,
bp.bpartner_employee as ship_bpartner_employee,

bploc.bploc_name as ship_bploc_name,
bploc.bploc_address1 as ship_bploc_address1,
bploc.bploc_address2 as ship_bploc_address2,
bploc.bploc_address3 as ship_bploc_address3,
bploc.bploc_address4 as ship_bploc_address4,
bploc.bploc_city as ship_bploc_city,
bploc.bploc_state as ship_bploc_state,
bploc.bploc_country_code as ship_bploc_country_code,
bploc.bploc_country_name as ship_bploc_country_name,

bpinv.bpartner_search_key as invoice_bpartner_search_key,
bpinv.bpartner_name as invoice_bpartner_name,
bpinv.bpartner_name2 as invoice_bpartner_name2,
bpinv.bpartner_created as invoice_bpartner_created,
bpinv.bpartner_updated as invoice_bpartner_updated,
bpinv.bpartner_customer as invoice_bpartner_customer,
bpinv.bpartner_vendor as invoice_bpartner_vendor,
bpinv.bpartner_employee as invoice_bpartner_employee,

bplocinv.bploc_name as invoice_bploc_name,
bplocinv.bploc_address1 as invoice_bploc_address1,
bplocinv.bploc_address2 as invoice_bploc_address2,
bplocinv.bploc_address3 as invoice_bploc_address3,
bplocinv.bploc_address4 as invoice_bploc_address4,
bplocinv.bploc_city as invoice_bploc_city,
bplocinv.bploc_state as invoice_bploc_state,
bplocinv.bploc_country_code as invoice_bploc_country_code,
bplocinv.bploc_country_name as invoice_bploc_country_name,

wh.warehouse_search_key,
wh.warehouse_name,
wh.warehouse_description,
wh.warehouse_active,
wh.warehouse_in_transit,
wh.warehouse_prevent_negative_inventory,
wh.warehouse_loc_address1,
wh.warehouse_loc_address2,
wh.warehouse_loc_address3,
wh.warehouse_loc_address4,
wh.warehouse_loc_city,
wh.warehouse_loc_state,
wh.warehouse_loc_country_code,
wh.warehouse_loc_country_name

from c_order ord
join bi_bpartner bp on ord.c_bpartner_id = bp.bpartner_id
join bi_bpartner bpinv on ord.bill_bpartner_id = bp.bpartner_id
join bi_bploc bploc on ord.c_bpartner_location_id = bploc.bpartner_location_id
join bi_bploc bplocinv on ord.bill_location_id = bploc.bpartner_location_id
join bi_client c on ord.ad_client_id = c.client_id
join bi_org o on ord.ad_org_id = o.org_id
join c_doctype dt on ord.c_doctype_id = dt.c_doctype_id
left join AD_Ref_List delrule on ord.deliveryrule = delrule.value and delrule.AD_Reference_ID=151
left join AD_Ref_List invrule on ord.invoicerule = invrule.value and invrule.AD_Reference_ID=150
left join bi_warehouse wh on ord.m_warehouse_id = wh.warehouse_id
;
SELECT 'order.'||column_name||',' as order FROM information_schema.columns WHERE  table_name   = 'bi_order';

CREATE VIEW bi_order_line AS
SELECT o.*,
ol.c_orderline_id,
ol.line as order_line_lineno,
prod.m_product_id,
prod.product_search_key,
prod.product_name,
prod.product_description,
prod.product_document_note,
prod.product_category_name,
uom.c_uom_id,
uom.uom_name,
uom.uom_search_key,
ol.qtyordered as order_line_qty_ordered,
ol.qtyentered as order_line_qty_entered,
ol.qtyinvoiced as order_line_qty_invoiced,
ol.qtydelivered as order_line_qty_delivered,
ol.description as order_line_description,
ol.priceentered as order_line_price_entered,
ol.linenetamt as order_line_linenetamt,
ol.created as order_line_created,
ol.updated as order_line_updated,
chg.charge_name,
chg.charge_description,
ol.c_tax_id
-- needs tax details here
FROM c_orderline ol
JOIN bi_order o ON ol.c_order_id=o.c_order_id
LEFT JOIN bi_product prod on ol.m_product_id = prod.m_product_id
LEFT JOIN bi_charge chg ON ol.c_charge_id = chg.c_charge_id
JOIN bi_uom uom on ol.c_uom_id=uom.c_uom_id
;
SELECT 'orderline.'||column_name||',' as orderline FROM information_schema.columns WHERE  table_name   = 'bi_order_line';

CREATE VIEW bi_invoice AS
SELECT
c.*,
inv.c_invoice_id,
inv.documentno as Invoice_DocumentNo,
inv.grandtotal AS Invoice_Grand_total,
inv.issotrx as Invoice_Sales_Transaction,
inv.docstatus as Invoice_document_status,
inv.dateinvoiced as Invoice_date_invoiced,
inv.created as invoice_created,
inv.updated as invoice_updated,
o.ad_org_id,
o.org_name,
o.org_search_key,
o.org_active,
bp.c_bpartner_id,
bp.bpartner_search_key,
bp.bpartner_name,
bp.bpartner_name2,
bp.bpartner_created,
bp.bpartner_customer,
bp.bpartner_vendor,
bp.bpartner_employee,
bpl.c_bpartner_location_id,
bpl.bploc_name,
bpl.bploc_address1,
bpl.bploc_address2,
bpl.bploc_address3,
bpl.bploc_address4,
bpl.bploc_city,
bpl.bploc_state,
bpl.bploc_country_code,
bpl.bploc_country_name,
dt.name as doctype_name
FROM c_invoice inv
JOIN bi_bpartner bp ON inv.c_bpartner_id = bp.c_bpartner_id
JOIN bi_bploc bpl ON inv.c_bpartner_location_id = bpl.c_bpartner_location_id
JOIN bi_client c ON inv.ad_client_id = c.ad_client_id
JOIN bi_org o ON inv.ad_org_id = o.ad_org_id
JOIN c_doctype dt ON inv.c_doctype_id = dt.c_doctype_id
;
SELECT 'invoice.'||column_name||',' as invoice FROM information_schema.columns WHERE  table_name   = 'bi_invoice';

CREATE VIEW bi_invoice_line AS
SELECT i.*,
il.c_invoiceline_id,
il.line as invoice_line_lineno,
il.description as invoice_line_description,
il.qtyinvoiced as invoice_line_qty_invoiced, 
il.priceactual as invoice_line_price_actual,
il.taxamt as invoice_line_tax_amt,
il.linetotalamt as invoice_line_linetotalamt,
il.linenetamt as invoice_line_linenetamt, 
il.created as invoice_line_created,
il.updated as invoice_line_updated,
p.m_product_id,
p.product_search_key,
p.product_name,
p.product_description,
p.product_document_note,
p.product_category_name,
chg.charge_name,
chg.charge_description, 
il.c_tax_id,
-- heed tax details here
uom.c_uom_id,
uom.uom_name,
uom.uom_search_key
-- orderline details go here
FROM c_invoiceline il 
JOIN bi_invoice i ON il.c_invoice_id=i.c_invoice_id
LEFT JOIN bi_order_line ol ON il.c_orderline_id = ol.c_orderline_id
LEFT JOIN bi_product p ON il.m_product_id = p.m_product_id
LEFT JOIN bi_uom uom ON il.c_uom_id=uom.c_uom_id
LEFT JOIN bi_charge chg ON il.c_charge_id=chg.c_charge_id
;
SELECT 'invoiceline.'||column_name||',' as invoiceline FROM information_schema.columns WHERE  table_name   = 'bi_invoice_line';

CREATE VIEW bi_inout AS
SELECT 
c.*,
o.ad_org_id,
o.org_name,
o.org_search_key,
o.org_active,
io.m_inout_id,
io.issotrx AS InOut_Sales_Transaction,
io.documentno AS InOut_DocumentNo,
io.docaction AS InOut_document_action,
io.docstatus AS InOut_document_status,
dt.name AS InOut_doctype_name,
io.description AS InOut_description,
io.dateordered AS InOut_date_ordered,
io.movementdate as inout_movement_date,
io.created as inout_created,
io.updated as inout_updated,
ord.order_DocumentNo,
ord.order_Grand_total,
ord.order_date_ordered,
inv.c_invoice_id,
inv.Invoice_DocumentNo,
inv.Invoice_Grand_total,
inv.Invoice_Sales_Transaction,
inv.Invoice_document_status,
inv.Invoice_date_invoiced,
bp.c_bpartner_id,
bp.bpartner_search_key,
bp.bpartner_name,
bp.bpartner_name2,
bp.bpartner_created,
bp.bpartner_customer,
bp.bpartner_vendor,
bp.bpartner_employee,
bpl.c_bpartner_location_id,
bpl.bploc_name,
bpl.bploc_address1,
bpl.bploc_address2,
bpl.bploc_address3,
bpl.bploc_address4,
bpl.bploc_city,
bpl.bploc_state,
bpl.bploc_country_code,
bpl.bploc_country_name
FROM m_inout io
JOIN bi_bpartner bp ON io.c_bpartner_id = bp.c_bpartner_id
JOIN bi_bploc bpl ON io.c_bpartner_location_id = bpl.c_bpartner_location_id
JOIN bi_client c ON io.ad_client_id = c.ad_client_id
JOIN bi_org o ON io.ad_org_id = o.ad_org_id
JOIN c_doctype dt ON io.c_doctype_id = dt.c_doctype_id
LEFT JOIN bi_order ord ON io.c_order_id=ord.c_order_id
LEFT JOIN bi_invoice inv ON io.c_invoice_id=inv.c_invoice_id
;
SELECT 'inout.'||column_name||',' as inout FROM information_schema.columns WHERE  table_name   = 'bi_inout';

CREATE VIEW bi_inout_line AS 
SELECT
c.*,
o.ad_org_id,
o.org_name,
o.org_search_key,
o.org_active,
iol.m_inoutline_id,
iol.line as inout_line_lineno,
iol.description as inout_line_description,
iol.movementqty as inout_line_movement_qty,
iol.created as inout_line_created,
iol.updated as inout_line_updated,
io.m_inout_id,
io.InOut_Sales_Transaction,
io.InOut_DocumentNo,
io.InOut_document_action,
io.InOut_document_status,
io.InOut_doctype_name,
io.InOut_description,
io.InOut_date_ordered,
io.InOut_movement_date,
ol.c_orderline_id,
ol.order_line_lineno,
ol.order_line_qty_ordered,
ol.order_line_qty_invoiced,
ol.order_line_description,
ol.order_line_linenetamt,
p.m_product_id,
p.product_search_key,
p.product_name,
p.product_description,
p.product_document_note,
p.product_active,
p.product_category_name,
uom.uom_name, 
uom.uom_search_key, 
chg.c_charge_id,
chg.charge_name,
chg.charge_description
FROM m_inoutline iol
JOIN bi_inout io ON iol.m_inout_id=io.m_inout_id
LEFT JOIN bi_charge chg ON iol.c_charge_id=chg.c_charge_id
LEFT JOIN bi_order_line ol ON iol.c_orderline_id = ol.c_orderline_id
LEFT JOIN bi_product p ON iol.m_product_id=p.m_product_id
LEFT JOIN bi_uom uom ON iol.c_uom_id=uom.c_uom_id
JOIN bi_client c ON iol.ad_client_id = c.ad_client_id
JOIN bi_org o ON iol.ad_org_id = o.ad_org_id
;
SELECT 'inoutline.'||column_name||',' as inoutline FROM information_schema.columns WHERE  table_name   = 'bi_inout_line';

CREATE VIEW bi_requisition AS
SELECT
c.*,
o.ad_org_id,
o.org_name,
o.org_search_key,
o.org_active,
reqn.m_requisition_id,
reqn.documentno AS requisition_documentno,
reqn.description AS requisition_description,
reqn.totallines AS requisition_total_lines,
reqn.daterequired AS requisition_date_required,
reqn.docstatus AS requisition_document_status,
reqn.datedoc AS requisition_date_doc,
reqn.created as requisition_created,
reqn.updated as requisition_updated,
dt.name AS doctype_name
FROM m_requisition reqn
JOIN bi_client c ON reqn.ad_client_id = c.ad_client_id
JOIN bi_org o ON reqn.ad_org_id = o.ad_org_id
JOIN c_doctype dt ON reqn.c_doctype_id = dt.c_doctype_id
;
SELECT 'requisition.'||column_name||',' as requisition FROM information_schema.columns WHERE  table_name   = 'bi_requisition';

CREATE VIEW bi_requisition_line AS
SELECT reqn.*,
rl.m_requisitionline_id,
rl.line as requisition_line_lineno,
p.m_product_id,
p.product_search_key,
p.product_name,
p.product_description,
p.product_document_note,
p.product_category_name,
rl.description as requisition_line_description,
rl.qty as requisition_line_qty, 
rl.priceactual as requisition_line_price,
rl.linenetamt as requisition_line_linenetamt, 
uom.c_uom_id,
uom.uom_name,
uom.uom_search_key,
ol.c_orderline_id,
ol.order_line_qty_ordered,
ol.order_line_qty_invoiced,
ol.order_line_description,
ol.order_line_linenetamt,
ol.c_tax_id,
-- need tax data here
bp.c_bpartner_id,
bp.bpartner_search_key,
bp.bpartner_name,
bp.bpartner_name2,
bp.bpartner_created,
bp.bpartner_customer,
bp.bpartner_vendor,
bp.bpartner_employee
FROM m_requisitionline rl
JOIN bi_requisition reqn ON rl.m_requisition_id=reqn.m_requisition_id
LEFT JOIN bi_order_line ol ON rl.c_orderline_id = ol.c_orderline_id
LEFT JOIN bi_product p ON rl.m_product_id = p.m_product_id
LEFT JOIN bi_uom uom ON rl.c_uom_id=uom.c_uom_id
LEFT JOIN bi_bpartner bp ON rl.c_bpartner_id=bp.c_bpartner_id
;
SELECT 'requisitionline.'||column_name||',' as requisitionline FROM information_schema.columns WHERE  table_name   = 'bi_requisition_line';

CREATE VIEW bi_request AS
SELECT 
c.*,
o.ad_org_id,
o.org_name,
o.org_search_key,
o.org_active,
req.r_request_id,
req.documentno as request_documentno,
reqtype.name AS request_type,
reqcat.name AS request_category,
reqstat.name AS request_status,
resol.name AS request_resolution,
req.priority as request_priority,
req.summary as request_summary,
req.datelastaction as request_date_last_action,
req.datenextaction as request_date_next_action,
req.lastresult as request_lastresult,
req.startdate as request_startdate,
req.closedate as request_closedate,
req.created as request_created,
req.updated as request_updated
FROM r_request req
JOIN r_requesttype reqtype ON req.r_requesttype_id = reqtype.r_requesttype_id
LEFT JOIN r_category reqcat ON req.r_category_id=reqcat.r_category_id
LEFT JOIN r_status reqstat ON req.r_status_id=reqstat.r_status_id
LEFT JOIN r_resolution resol ON req.r_resolution_id=resol.r_resolution_id
LEFT JOIN bi_bpartner bp ON req.c_bpartner_id = bp.c_bpartner_id
JOIN bi_client c ON req.ad_client_id = c.ad_client_id
JOIN bi_org o ON req.ad_org_id = o.ad_org_id
LEFT JOIN bi_order ord ON req.c_order_id=ord.c_order_id
LEFT JOIN bi_product p ON req.m_product_id=p.m_product_id
;
SELECT 'request.'||column_name||',' as request FROM information_schema.columns WHERE  table_name   = 'bi_request';

CREATE VIEW bi_production as 
SELECT
c.*,
o.*,
production.m_production_id,
production.documentno as production_documentno,
production.name as production_name,
production.description as production_description,
production.datepromised as production_date_promised,
production.movementdate as production_movement_date,
production.m_product_id,
production.m_locator_id,

-- add locator here

production.productionqty as production_qty,
production.iscreated as production_records_created,
production.isactive as production_active,
production.docstatus as production_document_status,
production.created as production_created,
production.updated as production_updated,
production.c_orderline_id, 

orderline.order_documentno,
orderline.order_grand_total,
orderline.order_sales_transaction,
orderline.order_document_status,
orderline.order_date_ordered,
orderline.doctype_name,
orderline.order_line_lineno,
orderline.order_line_qty_ordered,
orderline.order_line_qty_entered,
orderline.order_line_qty_invoiced,
orderline.order_line_qty_delivered,
orderline.order_line_description,
orderline.order_line_price_entered,
orderline.order_line_linenetamt,

prod.product_search_key,
prod.product_name,
prod.product_description,
prod.product_document_note,
prod.product_active,
prod.product_category_name,
prod.uom_name,

bp.bpartner_search_key,
bp.bpartner_name,
bp.bpartner_name2,
bp.bpartner_created,
bp.bpartner_customer,
bp.bpartner_vendor

from M_Production production
left join bi_product prod on production.m_product_id = prod.m_product_id
join bi_client c on production.ad_client_id = c.ad_client_id
join bi_org o on production.ad_org_id = o.ad_org_id
left join bi_order_line orderline on production.c_orderline_id = orderline.c_orderline_id
left join bi_bpartner bp on production.c_bpartner_id = bp.c_bpartner_id
;
SELECT 'production.'||column_name||',' as production FROM information_schema.columns WHERE  table_name   = 'bi_production';


CREATE VIEW bi_production_line as
select 
production.client_name,
production.ad_client_id,
production.org_name,
production.org_search_key,
production.ad_org_id,
production.org_active,
production.m_production_id,
production.production_documentno,
production.production_name,
production.production_description,
production.production_date_promised,
production.production_movement_date,
production.m_product_id,
production.production_qty,
production.production_records_created,
production.production_active,
production.production_document_status,

productionline.m_productionline_id,
productionline.line as producitonline_lineno,
productionline.isendproduct as production_line_end_product,
productionline.isactive as production_line_active,
productionline.plannedqty as production_line_qty_planned,
productionline.qtyused as production_line_qty_used,
productionline.description as production_line_description,
productionline.created as production_line_created,
productionline.updated as production_line_updated,

productionline.m_locator_id,
-- insert locator here

prod.product_search_key,
prod.product_name,
prod.product_description,
prod.product_document_note,
prod.product_active,
prod.product_category_name,
prod.uom_name

from m_productionline productionline
join bi_production production on productionline.m_production_id = production.m_production_id
left join bi_product prod on productionline.m_product_id = prod.m_product_id
;
SELECT 'productionline.'||column_name||',' as produtionline FROM information_schema.columns WHERE  table_name   = 'bi_production_line';

-- show all SQL to update BI access
SELECT   CONCAT('GRANT SELECT ON adempiere.', TABLE_NAME, ' to biaccess;')
FROM     INFORMATION_SCHEMA.TABLES
WHERE    TABLE_SCHEMA = 'adempiere'
    AND TABLE_NAME LIKE 'bi_%'
;