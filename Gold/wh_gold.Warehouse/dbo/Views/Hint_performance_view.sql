-- Auto Generated (Do not modify) 3B6B9022920DFFC9CD068D37DEC38311C217889F2F688DD332550E5F511BF674
    CREATE   VIEW dbo.Hint_performance_view AS

    select 
        dh.hint_id,
        dh.hint_label,
        dh.hint_stage,
        count(*) as total_requested,
        count(*) as total_shown,
        avg(fh.guesses_after_hint * 1.0) as avg_guesses_after_hint,
        avg(fh.is_session_success * 1.0) as success_after_hint_rate,
        fh.event_source,
        fh.is_simulated
    from [wh_gold].[dbo].[fact_hint_usage] fh
    join [wh_gold].[dbo].[dim_hint_gold] dh
        on fh.hint_id = dh.hint_id
    group by 
        dh.hint_id,
        dh.hint_label,
        dh.hint_stage, 
        fh.event_source,
        fh.is_simulated