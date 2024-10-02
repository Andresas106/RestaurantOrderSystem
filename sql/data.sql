create table category (
    id_category bigint auto_increment primary key,
    name varchar(50) not null,
    color varchar(7) not null
)ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

create table dishes(
    id_dish bigint primary key,
    name varchar(200) not null,
    description varchar(500) not null,
    price float not null,
    foto mediumblob not null,
    available bool not null,
    category not null,
    foreign key(category) references category(id_category),
)ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

