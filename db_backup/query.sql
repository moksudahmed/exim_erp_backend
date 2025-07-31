DROP VIEW public.journal_summary;
CREATE VIEW journal_summary AS
SELECT
    j.id,
    j.created_at,
    j.description,
    a.account_name,
    a.account_type,
    l.debit,
    l.credit
FROM journal_entries j
JOIN journal_lines l ON j.id = l.journal_id
JOIN account a ON l.account_id = a.account_id
ORDER BY j.id, l.line_id;

SELECT * FROM journal_summary;


CREATE VIEW account_ledger AS
SELECT
    a.account_name,
    j.created_at,
    j.description,
    l.debit,
    l.credit,
    (COALESCE(l.debit, 0) - COALESCE(l.credit, 0)) AS amount,
    SUM(COALESCE(l.debit, 0) - COALESCE(l.credit, 0))
        OVER (PARTITION BY l.account_id ORDER BY j.created_at, j.id) AS running_balance
FROM journal_lines l
JOIN journal_entries j ON j.id = l.journal_id
JOIN account a ON a.account_id = l.account_id
ORDER BY a.account_name, j.created_at;


-- Monthly L/C Summary Report with Account Join
SELECT
    DATE_TRUNC('month', je.created_at) AS month,
    SUM(CASE WHEN acc.account_name = 'Inventory' THEN jl.amount ELSE 0 END) AS total_inventory,
    SUM(CASE WHEN acc.account_name = 'L/C Commission' THEN jl.amount ELSE 0 END) AS total_lc_commission,
    SUM(CASE WHEN acc.account_name = 'Bank' AND jl.debitcredit = 'CREDIT' THEN jl.amount ELSE 0 END) AS total_bank_payment,
    SUM(CASE WHEN acc.account_name = 'Supplier' AND jl.debitcredit = 'CREDIT' THEN jl.amount ELSE 0 END) AS supplier_outstanding
FROM journal_entries je
JOIN journal_items jl ON jl.journal_entry_id = je.id
JOIN account acc ON acc.account_id = jl.account_id
WHERE je.ref_no IS NOT NULL
GROUP BY month
ORDER BY month;



1.
INSERT INTO journal_entries (description)
VALUES ('LC opened with bank margin blocked');

INSERT INTO public.journal_entries(ref_no, account_type, company, user_id, description)
    VALUES ('LC', 'EXPENSE', 'LC',1, 'LC opened with bank margin blocked');

-- Dr L/C Margin
INSERT INTO journal_lines (journal_id, account_id, debit)
VALUES (151, (SELECT account_id FROM account WHERE account_name = 'L/C Anisul Haque'), 100000.00);

-- Cr Bank
INSERT INTO journal_lines (journal_id, account_id, credit)
VALUES (151, (SELECT account_id FROM account WHERE account_name = 'Bank A/C'), 100000.00);

--OR

INSERT INTO public.journal_items(
            journal_entry_id, narration, debitcredit, amount, account_id)
    VALUES (151, 'L/C Anisul Haque', 'DEBIT', 100000.00,(SELECT account_id FROM account WHERE account_name = 'L/C Anisul Haque'));

INSERT INTO public.journal_items(
            journal_entry_id, narration, debitcredit, amount, account_id)
    VALUES (151, 'Bank A/C', 'CREDIT', 100000.00,(SELECT account_id FROM account WHERE account_name = 'L/C Anisul Haque'));

2.


INSERT INTO journal_entries (description)
VALUES ('Goods received under L/C');

INSERT INTO public.journal_entries(ref_no, account_type, company, user_id, description)
    VALUES ('LC', 'EXPENSE', 'LC',1, 'Goods received under L/C');


-- Dr Inventory
INSERT INTO journal_lines (journal_id, account_id, debit)
VALUES (152, (SELECT account_id FROM account WHERE account_name = 'Inventory'), 100000.00);

-- Cr Accounts Payable
INSERT INTO journal_lines (journal_id, account_id, credit)
VALUES (152, (SELECT account_id FROM account WHERE account_name = 'Accounts Payable'), 100000.00);

---OR

INSERT INTO public.journal_items(
            journal_entry_id, narration, debitcredit, amount, account_id)
    VALUES (152, 'L/C Anisul Haque', 'DEBIT', 100000.00,(SELECT account_id FROM account WHERE account_name = 'Inventory'));

INSERT INTO public.journal_items(
            journal_entry_id, narration, debitcredit, amount, account_id)
    VALUES (152, 'Bank A/C', 'CREDIT', 100000.00,(SELECT account_id FROM account WHERE account_name = 'Accounts Payable'));

3.


INSERT INTO journal_entries (description)
VALUES ('Bank L/C charges');

INSERT INTO public.journal_entries(ref_no, account_type, company, user_id, description)
    VALUES ('LC', 'EXPENSE', 'LC',1, 'Bank L/C charges');

-- Dr L/C Charges (Expense)
INSERT INTO journal_lines (journal_id, account_id, debit)
VALUES (153, (SELECT account_id FROM account WHERE account_name = 'L/C Charges'), 500.00);

-- Cr Bank
INSERT INTO journal_lines (journal_id, account_id, credit)
VALUES (153, (SELECT account_id FROM account WHERE account_name = 'Bank A/C'), 500.00);

--OR

INSERT INTO public.journal_items(
            journal_entry_id, narration, debitcredit, amount, account_id)
    VALUES (153, 'L/C Anisul Haque', 'DEBIT',  500.00,(SELECT account_id FROM account WHERE account_name = 'L/C Charges'));

INSERT INTO public.journal_items(
            journal_entry_id, narration, debitcredit, amount, account_id)
    VALUES (153, 'Bank A/C', 'CREDIT',  500.00,(SELECT account_id FROM account WHERE account_name = 'Bank A/C'));

4.

INSERT INTO journal_entries (description)
VALUES ('Settlement to supplier under L/C');

INSERT INTO public.journal_entries(ref_no, account_type, company, user_id, description)
    VALUES ('LC', 'EXPENSE', 'LC',1, 'Settlement to supplier under L/C');


-- Dr Accounts Payable
INSERT INTO journal_lines (journal_id, account_id, debit)
VALUES (154, (SELECT account_id FROM account WHERE account_name = 'Accounts Payable'), 100000.00);

-- Cr L/C Margin
INSERT INTO journal_lines (journal_id, account_id, credit)
VALUES (154, (SELECT account_id FROM account WHERE account_name = 'L/C Anisul Haque'), 100000.00);

---OR
INSERT INTO public.journal_items(
            journal_entry_id, narration, debitcredit, amount, account_id)
    VALUES (154, 'L/C Anisul Haque', 'DEBIT', 100000.00,(SELECT account_id FROM account WHERE account_name = 'Accounts Payable'));

INSERT INTO public.journal_items(
            journal_entry_id, narration, debitcredit, amount, account_id)
    VALUES (154, 'Bank A/C', 'CREDIT', 100000.00,(SELECT account_id FROM account WHERE account_name = 'L/C Anisul Haque'));

