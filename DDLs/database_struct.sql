create type status_type as enum ('New', 'In processing', 'Ready to delivery', 'Completed', 'Discarded');

alter type status_type owner to rtysem;

create type payment_type as enum ('cash', 'card', 'transaction');

alter type payment_type owner to rtysem;

create table category
(
    categoryid integer     not null
        constraint categoryid
            primary key,
    name       varchar(20) not null,
    constraint category_unq
        unique (categoryid, name)
);

alter table category
    owner to rtysem;

create table supplier
(
    supplierid   integer     not null
        constraint supplierid_pk
            primary key,
    contactname  varchar(20) not null,
    suppliername varchar(20) not null,
    phone        varchar(20) not null,
    email        varchar(20) not null,
    deliveryname varchar(20) not null,
    constraint supplier_unq
        unique (supplierid, phone, email)
);

alter table supplier
    owner to rtysem;

create table product
(
    productid    integer     not null
        constraint productid
            primary key,
    name         varchar(20) not null,
    description  text,
    costprice    integer     not null,
    retailprice  integer     not null,
    article      integer     not null
        constraint article_unq
            unique,
    supplierdate date,
    category_id  integer     not null
        constraint category_id_fk
            references category,
    supplier_id  integer     not null
        constraint supplier_id_fk
            references supplier,
    parameters   json        not null,
    constraint product_unq
        unique (name, article, productid)
);

alter table product
    owner to rtysem;

create index fk__index
    on product (supplier_id, category_id);

create table warehouse
(
    warehouseid integer      not null
        constraint warehouseid_pk
            primary key,
    name        varchar(20)  not null,
    address     varchar(120) not null,
    constraint warehouse_unq
        unique (name, address)
);

alter table warehouse
    owner to rtysem;

create table product_and_warehouses
(
    product_and_warehousesid          integer not null
        constraint product_and_warehousesid_pk
            primary key,
    product_id                        integer not null
        constraint product_id___fk
            references product,
    warehouse_id                      integer not null
        constraint warehousesid_fk
            references warehouse,
    quantity_of_product_in_warehouses integer not null
);

alter table product_and_warehouses
    owner to rtysem;

create index product_and_warehouses_idx_fk
    on product_and_warehouses (product_id, warehouse_id)
    nulls not distinct;

create table client
(
    clientid   integer     not null
        constraint clientid_pk
            primary key,
    username   varchar(20) not null,
    first_name varchar(20) not null,
    last_name  varchar(20) not null,
    phone      varchar(20) not null,
    email      varchar(20) not null,
    constraint client_unq
        unique (clientid, username, email, phone)
);

alter table client
    owner to rtysem;

create table "Order"
(
    orderid       integer                not null
        constraint orderid_pk
            primary key,
    name          varchar(20)            not null,
    status        art_rooms.status_type  not null,
    total_amount  integer                not null,
    payment_type  art_rooms.payment_type not null,
    creation_data date                   not null,
    client_id     integer                not null
        constraint client__fk
            references client,
    constraint order_unq
        unique (orderid, name)
);

alter table "Order"
    owner to rtysem;

create index order_client_id_index
    on "Order" (client_id);

create table product_and_order
(
    product_and_order_id         integer not null
        constraint product_and_orderid_pk
            primary key,
    product_id                   integer not null
        constraint product_id_fk
            references product,
    order_id                     integer not null
        constraint order_id_fk
            references "Order",
    quantity_of_ordered_products integer not null
);

alter table product_and_order
    owner to rtysem;

