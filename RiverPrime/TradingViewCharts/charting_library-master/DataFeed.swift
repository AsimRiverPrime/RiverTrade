//
//  DataFeed 2.swift
//  RiverPrime
//
//  Created by Ross Rostane on 24/01/2025.
//

//
//class DataFeed {
//    constructor() {
//        this.socket = new WebSocket("wss://mbe.riverprime.com/mobile_web_socket");
//        this.socket.onmessage = this.onMessage.bind(this);
//    }
//
//    onMessage(event) {
//        const data = JSON.parse(event.data);
//        // Process the WebSocket message (e.g., update the chart)
//    }
//
//    onReady(callback) {
//        setTimeout(() => callback({ supports_marks: false, supports_timescale_marks: false, supports_time: true }), 0);
//    }
//
//    resolveSymbol(symbolName, onSymbolResolvedCallback, onResolveErrorCallback) {
//        const symbolInfo = {
//            name: symbolName,
//            ticker: symbolName,
//            session: "24x7",
//            timezone: "Etc/UTC",
//            has_intraday: true,
//            supported_resolutions: ["1", "5", "15", "60", "D"],
//            volume_precision: 2,
//        };
//        onSymbolResolvedCallback(symbolInfo);
//    }
//
//    getBars(symbolInfo, resolution, from, to, onHistoryCallback, onErrorCallback) {
//        this.socket.send(JSON.stringify({
//            event_name: "get_chart_history",
//            data: { symbol: symbolInfo.name, from, to }
//        }));
//
//        this.socket.onmessage = (event) => {
//            const response = JSON.parse(event.data);
//            if (response.event_name === "chart_history") {
//                const bars = response.data.map(bar => ({
//                    time: bar.time * 1000, // Convert to milliseconds
//                    low: bar.low,
//                    high: bar.high,
//                    open: bar.open,
//                    close: bar.close,
//                    volume: bar.volume,
//                }));
//                onHistoryCallback(bars, { noData: bars.length === 0 });
//            }
//        };
//    }
//
//    subscribeBars(symbolInfo, resolution, onRealtimeCallback, subscriberUID, onResetCacheNeededCallback) {
//        this.socket.onmessage = (event) => {
//            const data = JSON.parse(event.data);
//            if (data.event_name === "realtime_data") {
//                const bar = {
//                    time: data.time * 1000,
//                    low: data.low,
//                    high: data.high,
//                    open: data.open,
//                    close: data.close,
//                    volume: data.volume,
//                };
//                onRealtimeCallback(bar);
//            }
//        };
//    }
//
//    unsubscribeBars(subscriberUID) {
//        // Handle unsubscription logic
//    }
//}
//
//window.tvWidget = new TradingView.widget({
//    symbol: "Gold", // Default symbol
//    datafeed: new DataFeed(),
//    interval: "1",
//    container_id: "tv_chart_container",
//    library_path: "./charting_library/",
//    locale: "en",
//    disabled_features: ["use_localstorage_for_settings"],
//    enabled_features: ["move_logo_to_main_pane"],
//    charts_storage_url: "https://saveload.tradingview.com",
//    charts_storage_api_version: "1.1",
//    client_id: "tradingview.com",
//    user_id: "public_user_id",
//});
